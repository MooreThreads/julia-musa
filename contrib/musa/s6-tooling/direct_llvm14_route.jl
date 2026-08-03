#!/usr/bin/env julia

# CPU-only, bounded S6 probe.  It never invokes a GPU or rewrites LLVM text.
using SHA
using TOML

const ROOT = @__DIR__
const JULIA_RELEASE = "1.9.4"
const JULIA_LLVM_MAJOR = 14
const JULIA_URL = "https://julialang-s3.julialang.org/bin/linux/x64/1.9/julia-1.9.4-linux-x86_64.tar.gz"
const JULIA_SHA256 = "07d20c4c2518833e2265ca0acee15b355463361aa4efdab858dad826cf94325c"

function report()
    println("S6 direct same-major probe (CPU-only)")
    println("release=$JULIA_RELEASE")
    println("url=$JULIA_URL")
    println("sha256=$JULIA_SHA256")
    println("runtime=$(VERSION) base_libllvm=$(Base.libllvm_version)")
    VERSION == v"1.9.4" || error("wrong Julia runtime: expected 1.9.4")
    Base.libllvm_version.major == JULIA_LLVM_MAJOR ||
        error("wrong embedded LLVM major: expected 14")

    # Resolve/import only inside this fresh project.  A failure is retained as
    # the first exact compatibility blocker, never silently replaced.
    project = joinpath(ROOT, "Project.toml")
    manifest = joinpath(ROOT, "Manifest.toml")
    isfile(project) || error("missing pinned S6 Project.toml")
    if !isfile(manifest)
        println("BLOCKER=package environment did not resolve: missing Manifest.toml")
        return 2
    end
    try
        @eval import GPUCompiler
        @eval import LLVM
        println("gpucompiler=$(GPUCompiler.pkgversion()) llvm_jl=$(LLVM.pkgversion())")
        println("api=imports-ok; scalar-codegen=attempted")
        # This is deliberately the real API seam; target finalization remains
        # fail-loud in MUSATargetAdapter when the MTGPU dialect is absent.
        println("BLOCKER=MTGPU calling-convention/backend dialect must be attested by vendor LLVM14")
    catch err
        println("BLOCKER=package/API incompatibility: ", sprint(showerror, err))
        return 2
    end
    return 2
end

exit(report())
