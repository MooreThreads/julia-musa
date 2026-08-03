using Test
using GPUCompiler
using LLVM

include("sealed_direct_route.jl")
using .SealedDirectRoute

# Prove each sealed device-only guard fails on a single bounded mutation.
function check_module(extra::String=""; triple::String=SealedDirectRoute.MTGPU_TRIPLE,
                      layout::String=SealedDirectRoute.MTGPU_DATA_LAYOUT,
                      callconv::Cuint=SealedDirectRoute.MTGPU_KERNEL_CALL_CONV,
                      cpu::String=SealedDirectRoute.MTGPU_CPU,
                      input_llvm::VersionNumber=LLVM.version(),
                      linked_libraries::Tuple=())
    text = """
    target datalayout = "$layout"
    target triple = "$triple"
    define void @scalar_kernel(i32 %x) {
      ret void
    }
    $extra
    """
    return GPUCompiler.JuliaContext() do _
        LLVM.@dispose mod = parse(LLVM.Module, text) begin
            entry = LLVM.functions(mod)["scalar_kernel"]
            LLVM.callconv!(entry, callconv)
            push!(LLVM.function_attributes(entry), LLVM.StringAttribute("target-cpu", cpu))
            validate_device_module(mod, entry; input_llvm, linked_libraries)
        end
    end
end

@testset "sealed Julia LLVM14 route API" begin
    @test VERSION == v"1.9.4"
    @test Base.libllvm_version == v"14.0.6"
    @test pkgversion(GPUCompiler) == v"0.26.2"
    @test pkgversion(LLVM) == v"6.6.0"
    @test LLVM.version() == v"14.0.6"
    @test check_module() === nothing

    mod, _ = compile_scalar_module()
    ir = string(mod)
    @test occursin("mul i32", ir)
    @test occursin("add i32", ir)
    @test occursin("store i32", ir)
    @test !occursin("swiftcc", ir)
end

@testset "mutation-sensitive device guards" begin
    mutations = (
        () -> check_module("define swiftcc void @host_helper() { ret void }"),
        () -> check_module("declare void @julia.gc_safepoint()"),
        () -> check_module("declare void @llvm.experimental.gc.safepoint()"),
        () -> check_module("declare void @ijl_apply_generic()"),
        () -> check_module("@bad = external addrspace(1) global i8"),
        () -> check_module(; triple="x86_64-unknown-linux-gnu"),
        () -> check_module(; layout="e-p:32:32"),
        () -> check_module(; callconv=Cuint(0)),
        () -> check_module(; cpu="mp_22"),
        () -> check_module(; input_llvm=v"15.0.0"),
        () -> check_module(; linked_libraries=("libdevice.bc",)),
    )
    for mutation in mutations
        @test_throws RouteError mutation()
    end
end
