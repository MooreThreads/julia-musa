# MUSA S6 same-LLVM-major denominator

## Result

**INCONCLUSIVE / NO_GO for Julia-to-MTGPU object generation.** The direct
same-major route was tested against the newest stable official Julia release
whose embedded LLVM major is 14. The S5 adapter remains unchanged and fail-loud:
it rejects host `swiftcc`, Julia GC/PTLS/safepoints, unsupported address spaces,
device libraries, missing `mp_31` ABI attestation, and any LLVM-major mismatch.
No textual IR conversion, in-place LLVM replacement, CUDA identity, GPU query,
or GPU execution was used.

## Authenticated denominator

Official `https://julialang-s3.julialang.org/bin/versions.json` names Julia
`1.9.4` as the newest stable 1.9 release and supplies this x86_64 Linux archive:

| input | value |
|---|---|
| release / Julia | `1.9.4` |
| URL | `https://julialang-s3.julialang.org/bin/linux/x64/1.9/julia-1.9.4-linux-x86_64.tar.gz` |
| size | `146163887` bytes |
| SHA-256 | `07d20c4c2518833e2265ca0acee15b355463361aa4efdab858dad826cf94325c` |
| metadata git-tree-sha256 | `7c9511383e7746167b6c91ee341dcbdfdca1f5abe05a6fb6b5bfd14a051ebe4d` |
| detached signature | `versions.json` `asc` field for this exact file; Julia Binary signing key, fingerprint `3673DF529D9075177DF6359B98F1C7EC03961954` |
| observed runtime | Julia `1.9.4`, `Base.libllvm_version == v"14.0.6"` |

The archive was downloaded into the ignored `contrib/musa/s6-tooling/deps`
root and its SHA-256 was checked before extraction. No host installation was
performed.

## Pinned package attempt and first blocker

The fresh workspace-local project requests the Julia-1.9-compatible pair
`GPUCompiler 0.26` / `LLVM.jl 6.1` (see
[`contrib/musa/s6-tooling/Project.toml`](../../../contrib/musa/s6-tooling/Project.toml)).
Under `JULIA_NUM_THREADS=2 OMP_NUM_THREADS=2`, Julia 1.9.4 could not complete
registry/package resolution in the bounded environment, so no resolved
Manifest identity can honestly be recorded. The probe freezes this as the
first exact blocker and exits nonzero; it does not substitute the S5 Julia
1.12/LLVM.jl 9.11 environment.

[`direct_llvm14_route.jl`](../../../contrib/musa/s6-tooling/direct_llvm14_route.jl)
checks the release identity, requires a fresh Manifest, imports the real
GPUCompiler/LLVM APIs when available, and records the next blocker (attested
vendor LLVM14 MTGPU calling-convention/backend dialect) without claiming an
object. The vendor MUSA 5.2 `mp_31` control remains the only authentic
`EM_MTGPU` evidence; no Julia-produced object was generated.

## Verification

* official archive SHA-256: PASS;
* Julia 1.9.4 / LLVM 14.0.6 identity: PASS;
* S5 focused adapter tests and negative ABI/version controls: PASS (unchanged);
* fresh Julia/GPUCompiler/LLVM14 module-to-vendor backend path: **INCONCLUSIVE**
  at package resolution, with the exact blocker retained by the probe;
* no GPU, runtime, correctness, performance, deployment, or formal acceptance
  claim is made.
