# Experimental MUSA target adapter contract

This isolated package records the bounded S5 Julia/GPUCompiler adapter contract.
It is not part of Julia's build, does not provide a MUSA runtime, and does not claim
GPU execution or successful MTGPU object generation.

The only target is `mtgpu-mt-musa` / `mp_31`, with the data layout emitted by the
authenticated MUSA 5.2.0 frontend. The scalar ABI admits address space 0 only.
Spaces 1--5 occur in the vendor layout, but their semantics were not established by
S2, so the adapter rejects them. Device-library mode is `none`: the authenticated
`libdevice.bc` and `libdevice.31.bc` inputs are LLVM 14 bitcode and are not linked
into LLVM 18 or LLVM 21 modules.

Before calling any backend, `invoke_backend` requires an MTGPU target, an LLVM major
equal to the module producer, and an explicit `musa-5.2-mtgpu-mp31` ABI attestation.
It then rejects host `swiftcc`, Julia runtime/GC/PTLS/safepoint dependencies,
unsupported address spaces, a wrong triple/layout/CPU/kernel convention, and device
libraries. Validation only rejects input; it never rewrites LLVM text.
Mainline LLVM 18 maps numeric convention ID 102 to an unrelated AArch64
convention, so module finalization also fails instead of substituting the number
for vendor `mtgpu_kernel`.

Run the CPU-only tests from this directory with:

```sh
OMP_NUM_THREADS=2 julia --project=. -t2 -e 'using Pkg; Pkg.test()'
```

The remaining backend requirement is an MTGPU backend at the same LLVM major as the
Julia producer (LLVM 18 for the S4 Julia 1.12.6 control; LLVM 21 for this checkout),
with vendor confirmation that it implements the recorded MUSA 5.2.0 `mp_31` ABI.
Vendor LLVM 14 is intentionally rejected before invocation.
