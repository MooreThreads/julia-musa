#!/usr/bin/env julia

# CPU-only, bounded S6 probe.  It never invokes a GPU or rewrites LLVM text.
const ROOT = @__DIR__
const JULIA_RELEASE = "1.9.4"
const JULIA_LLVM_MAJOR = 14
const JULIA_URL = "https://julialang-s3.julialang.org/bin/linux/x64/1.9/julia-1.9.4-linux-x86_64.tar.gz"
const JULIA_SHA256 = "07d20c4c2518833e2265ca0acee15b355463361aa4efdab858dad826cf94325c"

include(joinpath(ROOT, "sealed_direct_route.jl"))

function report()
    println("S6 direct same-major probe (CPU-only)")
    println("release=$JULIA_RELEASE")
    println("url=$JULIA_URL")
    println("sha256=$JULIA_SHA256")
    println("runtime=$(VERSION) base_libllvm=$(Base.libllvm_version)")
    VERSION == v"1.9.4" || error("wrong Julia runtime: expected 1.9.4")
    Base.libllvm_version.major == JULIA_LLVM_MAJOR ||
        error("wrong embedded LLVM major: expected 14")

    project = joinpath(ROOT, "Project.toml")
    manifest = joinpath(ROOT, "Manifest.toml")
    isfile(project) || error("missing pinned S6 Project.toml")
    isfile(manifest) || error("missing sealed S6 Manifest.toml")
    try
        @eval import GPUCompiler
        @eval import LLVM
        println("gpucompiler=$(pkgversion(GPUCompiler)) llvm_jl=$(pkgversion(LLVM))")
        SealedDirectRoute.verify_receipt(joinpath(ROOT, "evidence"))
    catch err
        println("BLOCKER=package/API incompatibility: ", sprint(showerror, err))
        return 2
    end
    return 0
end

exit(report())
