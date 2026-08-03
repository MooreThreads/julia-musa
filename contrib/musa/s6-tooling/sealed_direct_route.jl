module SealedDirectRoute

using GPUCompiler
using LLVM
using SHA

export RouteError, compile_scalar_module, validate_device_module, run_route

const MTGPU_TRIPLE = "mtgpu-mt-musa"
const MTGPU_CPU = "mp_31"
const MTGPU_DATA_LAYOUT =
    "e-p:64:64:64:64-p1:64:64:64:64-p2:64:64:64:64-p3:32:32-" *
    "p4:32:32-p5:64:64-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128"
const MTGPU_KERNEL_CALL_CONV = Cuint(102)
const EXPECTED_JULIA = v"1.9.4"
const EXPECTED_LLVM = v"14.0.6"

struct RouteError <: Exception
    message::String
end
Base.showerror(io::IO, err::RouteError) = print(io, err.message)

struct MTGPUCompilerTarget <: GPUCompiler.AbstractCompilerTarget end
struct MTGPUCompilerParams <: GPUCompiler.AbstractCompilerParams end

GPUCompiler.llvm_triple(::MTGPUCompilerTarget) = MTGPU_TRIPLE
GPUCompiler.llvm_datalayout(::MTGPUCompilerTarget) = MTGPU_DATA_LAYOUT
GPUCompiler.llvm_machine(::MTGPUCompilerTarget) = nothing
GPUCompiler.runtime_module(::GPUCompiler.CompilerJob{MTGPUCompilerTarget}) =
    throw(RouteError("Julia device runtime is unavailable for the sealed scalar route"))
GPUCompiler.uses_julia_runtime(::GPUCompiler.CompilerJob{MTGPUCompilerTarget}) = false
GPUCompiler.can_safepoint(::GPUCompiler.CompilerJob{MTGPUCompilerTarget}) = false
GPUCompiler.link_libraries!(::GPUCompiler.CompilerJob{MTGPUCompilerTarget},
                            ::LLVM.Module, ::Vector{String}) =
    throw(RouteError("device-library inputs are prohibited for the sealed scalar route"))

function GPUCompiler.finish_module!(job::GPUCompiler.CompilerJob{MTGPUCompilerTarget},
                                    mod::LLVM.Module, entry::LLVM.Function)
    job.config.kernel || throw(RouteError("the MTGPU entry must be a device kernel"))
    LLVM.triple!(mod, MTGPU_TRIPLE)
    LLVM.callconv!(entry, MTGPU_KERNEL_CALL_CONV)
    push!(LLVM.function_attributes(entry), LLVM.StringAttribute("target-cpu", MTGPU_CPU))
    return entry
end

function GPUCompiler.finish_ir!(::GPUCompiler.CompilerJob{MTGPUCompilerTarget},
                                mod::LLVM.Module, entry::LLVM.Function)
    LLVM.triple!(mod, MTGPU_TRIPLE)
    LLVM.datalayout!(mod, MTGPU_DATA_LAYOUT)
    return entry
end

function scalar_kernel(out::Ptr{UInt32}, x::UInt32, y::UInt32)
    unsafe_store!(out, UInt32(3) * x + y)
    return
end

function require_denominator()
    VERSION == EXPECTED_JULIA || throw(RouteError(
        "wrong Julia denominator: expected $EXPECTED_JULIA, got $VERSION"))
    Base.libllvm_version == EXPECTED_LLVM || throw(RouteError(
        "wrong embedded LLVM denominator: expected $EXPECTED_LLVM, got $(Base.libllvm_version)"))
    LLVM.version() == EXPECTED_LLVM || throw(RouteError(
        "LLVM.jl is not using embedded LLVM $EXPECTED_LLVM: got $(LLVM.version())"))
    return nothing
end

function validate_device_module(mod::LLVM.Module, entry::LLVM.Function;
                                input_llvm::VersionNumber=LLVM.version(),
                                linked_libraries::Tuple=())
    require_denominator()
    input_llvm.major == EXPECTED_LLVM.major || throw(RouteError(
        "module LLVM $(input_llvm.major) does not match sealed LLVM $(EXPECTED_LLVM.major)"))
    LLVM.triple(mod) == MTGPU_TRIPLE || throw(RouteError("wrong MTGPU target triple"))
    string(LLVM.datalayout(mod)) == MTGPU_DATA_LAYOUT ||
        throw(RouteError("wrong MTGPU data layout"))
    LLVM.callconv(entry) == MTGPU_KERNEL_CALL_CONV ||
        throw(RouteError("device entry is missing MTGPU convention 102"))
    attributes = collect(LLVM.function_attributes(entry))
    any(attribute -> attribute isa LLVM.StringAttribute &&
                     LLVM.kind(attribute) == "target-cpu" &&
                     LLVM.value(attribute) == MTGPU_CPU, attributes) ||
        throw(RouteError("device entry is missing target-cpu=mp_31"))
    isempty(linked_libraries) ||
        throw(RouteError("device-library inputs are prohibited for the sealed scalar route"))

    ir = string(mod)
    occursin(r"\bswiftcc\b", ir) &&
        throw(RouteError("host swiftcc leaked into the device module"))
    occursin(r"(?:julia|llvm\.julia)\.gc|gcstack|@i?jl_gc_", ir) &&
        throw(RouteError("Julia GC state leaked into the device module"))
    occursin(r"safepoint|julia\.ptls", ir) &&
        throw(RouteError("Julia safepoint or PTLS state leaked into the device module"))
    occursin(r"declare[^\n]*@(?:julia\.|ijl_|jl_)", ir) &&
        throw(RouteError("Julia host runtime declaration leaked into the device module"))
    for found in eachmatch(r"addrspace\(([0-9]+)\)", ir)
        space = parse(Int, found.captures[1])
        space == 0 || throw(RouteError(
            "MTGPU address space $space is unsupported by the sealed scalar route"))
    end
    return nothing
end

function compile_scalar_module()
    require_denominator()
    source = GPUCompiler.methodinstance(typeof(scalar_kernel),
                                        Tuple{Ptr{UInt32}, UInt32, UInt32},
                                        Base.get_world_counter())
    config = GPUCompiler.CompilerConfig(MTGPUCompilerTarget(), MTGPUCompilerParams();
                                        kernel=true, name="julia_scalar_kernel")
    job = GPUCompiler.CompilerJob(source, config)
    return GPUCompiler.JuliaContext() do _
        mod, meta = GPUCompiler.compile(:llvm, job; libraries=false, optimize=true,
                                        cleanup=true, strip=false, validate=true)
        validate_device_module(mod, meta.entry)
        return mod, meta
    end
end

function require_fresh_outputs(paths)
    for path in paths
        ispath(path) && throw(RouteError("refusing to overwrite retained evidence: $path"))
    end
    return nothing
end

function run_checked(cmd::Cmd, log_path::String)
    open(log_path, "w") do io
        process = run(pipeline(cmd; stdout=io, stderr=io); wait=false)
        wait(process)
        success(process) || throw(RouteError(
            "command failed with exit $(process.exitcode); see $log_path: $cmd"))
    end
    return nothing
end

function run_route(output_dir::AbstractString, vendor_root::AbstractString="/usr/local/musa")
    require_denominator()
    isdir(output_dir) || mkdir(output_dir)
    bitcode = joinpath(output_dir, "julia-scalar-mtgpu.bc")
    julia_ir = joinpath(output_dir, "julia-scalar-mtgpu.ll")
    vendor_ir = joinpath(output_dir, "vendor-readback-mtgpu.ll")
    object = joinpath(output_dir, "julia-scalar-mp31.o")
    llc_log = joinpath(output_dir, "vendor-llc.log")
    readelf_log = joinpath(output_dir, "readelf-header.log")
    objdump_log = joinpath(output_dir, "vendor-objdump.log")
    dis_log = joinpath(output_dir, "vendor-dis.log")
    require_fresh_outputs((bitcode, julia_ir, vendor_ir, object, llc_log,
                           readelf_log, objdump_log, dis_log))

    mod, _ = compile_scalar_module()
    open(bitcode, "w") do io
        write(io, mod)
    end
    write(julia_ir, string(mod))

    llvm_dis = joinpath(vendor_root, "bin", "llvm-dis")
    llc = joinpath(vendor_root, "bin", "llc")
    objdump = joinpath(vendor_root, "bin", "llvm-objdump")
    for tool in (llvm_dis, llc, objdump)
        isfile(tool) || throw(RouteError("missing authenticated vendor tool: $tool"))
    end
    run_checked(`$llvm_dis $bitcode -o $vendor_ir`, dis_log)
    vendor_text = read(vendor_ir, String)
    occursin(r"define[^\n]*\bmtgpu_kernel\b[^\n]*@", vendor_text) ||
        throw(RouteError("vendor LLVM14 did not authenticate convention 102 as mtgpu_kernel"))
    occursin("\"target-cpu\"=\"mp_31\"", vendor_text) ||
        throw(RouteError("vendor LLVM14 readback lost target-cpu=mp_31"))

    run_checked(`$llc -mtriple=$MTGPU_TRIPLE -mcpu=$MTGPU_CPU -filetype=obj $bitcode -o $object`,
                llc_log)
    run_checked(`/usr/bin/readelf -h $object`, readelf_log)
    run_checked(`$objdump -f $object`, objdump_log)
    verify_receipt(output_dir)

    return nothing
end

function verify_receipt(output_dir::AbstractString)
    julia_ir = joinpath(output_dir, "julia-scalar-mtgpu.ll")
    bitcode = joinpath(output_dir, "julia-scalar-mtgpu.bc")
    vendor_ir = joinpath(output_dir, "vendor-readback-mtgpu.ll")
    object = joinpath(output_dir, "julia-scalar-mp31.o")
    objdump_log = joinpath(output_dir, "vendor-objdump.log")
    for path in (julia_ir, bitcode, vendor_ir, object, objdump_log)
        isfile(path) || throw(RouteError("missing retained route evidence: $path"))
    end
    vendor_text = read(vendor_ir, String)
    occursin(r"define[^\n]*\bmtgpu_kernel\b[^\n]*@", vendor_text) ||
        throw(RouteError("retained vendor readback lacks mtgpu_kernel"))
    occursin("\"target-cpu\"=\"mp_31\"", vendor_text) ||
        throw(RouteError("retained vendor readback lacks target-cpu=mp_31"))
    object_bytes = read(object)
    length(object_bytes) >= 20 || throw(RouteError("retained object has a truncated ELF header"))
    object_bytes[19:20] == UInt8[0xfd, 0x00] || throw(RouteError(
        "retained object e_machine is not the vendor EM_MTGPU value 253"))
    objdump = read(objdump_log, String)
    occursin("file format elf64-mtgpu", objdump) && occursin("architecture: mtgpu", objdump) ||
        throw(RouteError("vendor object inspection does not identify MTGPU"))

    println("julia_ir_sha256=", bytes2hex(sha256(read(julia_ir))))
    println("julia_bitcode_sha256=", bytes2hex(sha256(read(bitcode))))
    println("mtgpu_object_sha256=", bytes2hex(sha256(read(object))))
    println("object=EM_MTGPU cpu=$MTGPU_CPU")
    return nothing
end

end

if abspath(PROGRAM_FILE) == @__FILE__
    if length(ARGS) == 1
        SealedDirectRoute.run_route(ARGS[1])
    elseif length(ARGS) == 2 && ARGS[1] == "--verify-existing"
        SealedDirectRoute.verify_receipt(ARGS[2])
    else
        error("usage: sealed_direct_route.jl [--verify-existing] OUTPUT_DIRECTORY")
    end
end
