module MUSATargetAdapter

using GPUCompiler
using LLVM

export MTGPUCompilerTarget, BackendIdentity, BackendCompatibilityError,
       DeviceABIError, invoke_backend, validate_device_ir, address_space_policy,
       device_library_policy

const MTGPU_TRIPLE = "mtgpu-mt-musa"
const MTGPU_CPU = "mp_31"
const MTGPU_DATA_LAYOUT =
    "e-p:64:64:64:64-p1:64:64:64:64-p2:64:64:64:64-p3:32:32-" *
    "p4:32:32-p5:64:64-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128"
const MTGPU_KERNEL_CALL_CONV = Cuint(102)
const MTGPU_ABI = "musa-5.2-mtgpu-mp31"

"""The scalar slice permits generic pointers only; MTGPU spaces 1--5 remain blocked."""
address_space_policy() = (supported=(0,), blocked=(1, 2, 3, 4, 5),
                          widths=(64, 64, 64, 32, 32, 64))

"""No device bitcode is linked until an LLVM-dialect-compatible library exists."""
device_library_policy() =
    (mode=:none, linked=(), blocked=("libdevice.bc", "libdevice.31.bc"))

struct BackendCompatibilityError <: Exception
    message::String
end
Base.showerror(io::IO, err::BackendCompatibilityError) = print(io, err.message)

struct DeviceABIError <: Exception
    message::String
end
Base.showerror(io::IO, err::DeviceABIError) = print(io, err.message)

"""Identity supplied by a backend owner before any backend process is invoked."""
struct BackendIdentity
    llvm_version::VersionNumber
    targets::Tuple{Vararg{Symbol}}
    abi::Union{Nothing,String}
end

"""An immutable, device-only GPUCompiler target for the bounded `mp_31` slice."""
struct MTGPUCompilerTarget <: GPUCompiler.AbstractCompilerTarget
    cpu::String
    producer_llvm::VersionNumber

    function MTGPUCompilerTarget(cpu::String=MTGPU_CPU;
                                 producer_llvm::VersionNumber=LLVM.version())
        cpu == MTGPU_CPU || throw(ArgumentError(
            "the bounded MTGPU slice supports only mp_31, got $(repr(cpu))"))
        new(cpu, producer_llvm)
    end
end

GPUCompiler.source_code(::MTGPUCompilerTarget) = "mtgpu"
GPUCompiler.llvm_triple(::MTGPUCompilerTarget) = MTGPU_TRIPLE
GPUCompiler.llvm_datalayout(::MTGPUCompilerTarget) = MTGPU_DATA_LAYOUT
GPUCompiler.uses_julia_runtime(::GPUCompiler.CompilerJob{MTGPUCompilerTarget}) = false
GPUCompiler.can_safepoint(::GPUCompiler.CompilerJob{MTGPUCompilerTarget}) = false
GPUCompiler.link_libraries!(::GPUCompiler.CompilerJob{MTGPUCompilerTarget}, ::LLVM.Module) =
    nothing

function require_compatible_backend(target::MTGPUCompilerTarget, backend::BackendIdentity,
                                    input_llvm::VersionNumber)
    :MTGPU in backend.targets || throw(BackendCompatibilityError(
        "backend has no MTGPU target; refusing backend invocation"))
    input_llvm.major == target.producer_llvm.major || throw(BackendCompatibilityError(
        "input LLVM $(input_llvm.major) does not match producer LLVM " *
        "$(target.producer_llvm.major); refusing backend invocation"))
    backend.llvm_version.major == input_llvm.major || throw(BackendCompatibilityError(
        "backend LLVM $(backend.llvm_version.major) cannot consume LLVM " *
        "$(input_llvm.major) input; refusing backend invocation"))
    backend.abi == MTGPU_ABI || throw(BackendCompatibilityError(
        "backend does not attest the $MTGPU_ABI ABI; refusing backend invocation"))
    return nothing
end

function GPUCompiler.llvm_machine(target::MTGPUCompilerTarget)
    backend = BackendIdentity(LLVM.version(), Tuple(LLVM.backends()), nothing)
    require_compatible_backend(target, backend, target.producer_llvm)
    triple = GPUCompiler.llvm_triple(target)
    machine_target = LLVM.Target(; triple)
    return LLVM.TargetMachine(machine_target, triple, target.cpu)
end

function GPUCompiler.finish_module!(job::GPUCompiler.CompilerJob{MTGPUCompilerTarget},
                                    mod::LLVM.Module, entry::LLVM.Function)
    # Mainline LLVM 18 assigns ID 102 to an unrelated AArch64 convention.
    throw(BackendCompatibilityError(
        "producer LLVM does not implement the MTGPU kernel convention 102; " *
        "refusing module finalization"))
end

function _target_value(ir::AbstractString, key::AbstractString)
    found = match(Regex("target " * key * " = \\\"([^\\\"]+)\\\""), ir)
    return found === nothing ? nothing : found.captures[1]
end

"""
    validate_device_ir(target, ir; input_llvm, linked_libraries=())

Validate the final textual serialization without modifying it. This deliberately acts
as a conservative last gate before an out-of-process backend: it is not an LLVM
downgrader or a substitute for parsing by a dialect-compatible backend.
"""
function validate_device_ir(target::MTGPUCompilerTarget, ir::AbstractString;
                            input_llvm::VersionNumber,
                            linked_libraries::Tuple=())
    _target_value(ir, "triple") == MTGPU_TRIPLE || throw(DeviceABIError(
        "device module must target $MTGPU_TRIPLE"))
    _target_value(ir, "datalayout") == MTGPU_DATA_LAYOUT || throw(DeviceABIError(
        "device module has the wrong MTGPU data layout"))
    occursin(Regex("define[^\\n]*\\bmtgpu_kernel\\b[^\\n]*@"), ir) ||
        throw(DeviceABIError("device entry must use MTGPU kernel calling convention 102"))
    occursin("\"target-cpu\"=\"$MTGPU_CPU\"", ir) || throw(DeviceABIError(
        "device entry must declare target-cpu=mp_31"))

    occursin(r"\bswiftcc\b", ir) && throw(DeviceABIError(
        "host Julia swiftcc leaked into the device module"))
    occursin(r"(?:julia|llvm\.julia)\.gc|gcstack|@i?jl_gc_", ir) &&
        throw(DeviceABIError("Julia GC state leaked into the device module"))
    occursin(r"safepoint|julia\.ptls", ir) && throw(DeviceABIError(
        "Julia safepoint or PTLS state leaked into the device module"))
    occursin(r"declare[^\n]*@(?:julia\.|ijl_|jl_)", ir) && throw(DeviceABIError(
        "Julia host runtime declaration leaked into the device module"))

    for found in eachmatch(r"addrspace\(([0-9]+)\)", ir)
        space = parse(Int, found.captures[1])
        space in address_space_policy().supported || throw(DeviceABIError(
            "MTGPU address space $space is not supported by the scalar ABI slice"))
    end
    isempty(linked_libraries) || throw(DeviceABIError(
        "the scalar ABI slice must not link device libraries"))
    input_llvm.major == target.producer_llvm.major || throw(DeviceABIError(
        "module LLVM $(input_llvm.major) does not match producer LLVM " *
        "$(target.producer_llvm.major)"))
    return nothing
end

"""Run `backend` only after the version, target, ABI, and device-module gates pass."""
function invoke_backend(backend::Function, target::MTGPUCompilerTarget,
                        identity::BackendIdentity, ir::AbstractString;
                        input_llvm::VersionNumber,
                        linked_libraries::Tuple=())
    require_compatible_backend(target, identity, input_llvm)
    validate_device_ir(target, ir; input_llvm, linked_libraries)
    return backend(ir)
end

end
