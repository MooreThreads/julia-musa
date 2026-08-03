using Test
using GPUCompiler
using LLVM
using MUSATargetAdapter

# Exercise the fail-before-backend target, version, and device-only ABI contract.
const LAYOUT = MUSATargetAdapter.MTGPU_DATA_LAYOUT
const DEVICE_IR = """
target datalayout = "$LAYOUT"
target triple = "mtgpu-mt-musa"
define mtgpu_kernel void @scalar_kernel(i32 %x) #0 {
  ret void
}
attributes #0 = { nounwind "target-cpu"="mp_31" }
"""

@testset "MTGPU target identity and policy" begin
    target = MTGPUCompilerTarget(; producer_llvm=v"18.1.7")
    @test GPUCompiler.llvm_triple(target) == "mtgpu-mt-musa"
    @test GPUCompiler.llvm_datalayout(target) == LAYOUT
    @test target.cpu == "mp_31"
    @test_throws ArgumentError MTGPUCompilerTarget("mp_22")
    @test address_space_policy().supported == (0,)
    @test address_space_policy().blocked == (1, 2, 3, 4, 5)
    @test device_library_policy().mode == :none
    @test device_library_policy().linked == ()

    LLVM.@dispose ctx = LLVM.Context() begin
        LLVM.@dispose mod = parse(LLVM.Module,
                                  "define void @scalar_kernel() { ret void }") begin
            entry = LLVM.functions(mod)["scalar_kernel"]
            LLVM.callconv!(entry, MUSATargetAdapter.MTGPU_KERNEL_CALL_CONV)
            push!(LLVM.function_attributes(entry),
                  LLVM.StringAttribute("target-cpu", target.cpu))
            @test LLVM.callconv(entry) == 102
            @test !occursin("mtgpu_kernel", string(mod))
            @test any(attribute -> LLVM.kind(attribute) == "target-cpu" &&
                                   LLVM.value(attribute) == "mp_31",
                      collect(LLVM.function_attributes(entry)))
        end
    end
end

@testset "backend version gate runs before invocation" begin
    target = MTGPUCompilerTarget(; producer_llvm=v"18.1.7")
    calls = Ref(0)
    backend(_) = (calls[] += 1; :object)
    vendor14 = BackendIdentity(v"14.0.0", (:X86, :MTGPU),
                               "musa-5.2-mtgpu-mp31")
    @test_throws BackendCompatibilityError invoke_backend(
        backend, target, vendor14, DEVICE_IR; input_llvm=v"18.1.7")
    @test calls[] == 0

    checkout_target = MTGPUCompilerTarget(; producer_llvm=v"21.1.8")
    @test_throws BackendCompatibilityError invoke_backend(
        backend, checkout_target, vendor14, DEVICE_IR; input_llvm=v"21.1.8")
    @test calls[] == 0

    no_mtgpu = BackendIdentity(v"18.1.7", (:X86,), "musa-5.2-mtgpu-mp31")
    @test_throws BackendCompatibilityError invoke_backend(
        backend, target, no_mtgpu, DEVICE_IR; input_llvm=v"18.1.7")
    @test calls[] == 0

    unattested = BackendIdentity(v"18.1.7", (:X86, :MTGPU), nothing)
    @test_throws BackendCompatibilityError invoke_backend(
        backend, target, unattested, DEVICE_IR; input_llvm=v"18.1.7")
    @test calls[] == 0
end

@testset "device-only ABI gate" begin
    target = MTGPUCompilerTarget(; producer_llvm=v"18.1.7")
    compatible = BackendIdentity(v"18.1.7", (:X86, :MTGPU),
                                 "musa-5.2-mtgpu-mp31")
    calls = Ref(0)
    backend(_) = (calls[] += 1; :object)

    @test invoke_backend(backend, target, compatible, DEVICE_IR;
                         input_llvm=v"18.1.7") == :object
    @test calls[] == 1

    leaks = (
        (DEVICE_IR * "define swiftcc void @host_helper() { ret void }\n", "swiftcc"),
        (replace(DEVICE_IR, "  ret void" =>
                 "  call void @julia.gc_safepoint()\n  ret void"), "GC"),
        (DEVICE_IR * "declare void @llvm.experimental.gc.safepoint()\n", "safepoint"),
        (DEVICE_IR * "declare void @ijl_apply_generic()\n", "runtime declaration"),
        (replace(DEVICE_IR, "  ret void" =>
                 "  %p = alloca i8, addrspace(1)\n  ret void"), "address space 1"),
        (replace(DEVICE_IR, "target triple = \"mtgpu-mt-musa\"" =>
                 "target triple = \"x86_64-unknown-linux-gnu\""), "target"),
        (replace(DEVICE_IR, LAYOUT => "e-p:32:32"), "data layout"),
        (replace(DEVICE_IR, "mtgpu_kernel" => "cc 102"),
         "kernel calling convention"),
        (replace(DEVICE_IR, "target-cpu\"=\"mp_31" => "target-cpu\"=\"mp_22"),
         "target-cpu"),
    )
    for (ir, reason) in leaks
        err = try
            invoke_backend(backend, target, compatible, ir; input_llvm=v"18.1.7")
            nothing
        catch caught
            caught
        end
        @test err isa DeviceABIError
        @test occursin(reason, sprint(showerror, err))
    end
    @test_throws DeviceABIError invoke_backend(
        backend, target, compatible, DEVICE_IR; input_llvm=v"18.1.7",
        linked_libraries=("libdevice.bc",))
    @test calls[] == 1
end

@testset "ordinary Julia behavior is unchanged" begin
    scalar(x::UInt32, y::UInt32) = UInt32(3) * x + y
    @test scalar(UInt32(4), UInt32(5)) == UInt32(17)
end
