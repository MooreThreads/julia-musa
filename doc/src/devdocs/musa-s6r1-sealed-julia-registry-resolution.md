# MUSA S6R1 sealed Julia/registry resolution and object receipt

## Technical result

Gluon task `764f239c-0697-4bcf-95ba-88752a12388e` started from exact
accepted S6 result `239925acf979d8c4cac8162610ebbf4bf575b97d`. The package-resolution
blocker is removed and the bounded direct path produced an authentic MTGPU
object. This is technical completion only, not formal acceptance or a GPU
runtime, correctness, or performance result.

The retained route is
[`contrib/musa/s6-tooling`](../../../contrib/musa/s6-tooling). It generates a
scalar `UInt32(3) * x + y` store with Julia/GPUCompiler, preserves Julia's
LLVM IR and bitcode, passes the bitcode without textual rewriting to the MUSA
5.2 vendor LLVM 14 MTGPU backend, and retains the resulting object. No CUDA
identity, replacement LLVM, GPU query, or GPU execution is involved.

## Authenticated Julia denominator

The mounted input was authenticated before extraction or execution:

| field | sealed value |
|---|---|
| archive | `/artifacts/julia-1.9.4-linux-x86_64-official.tar.gz` |
| official URL | `https://julialang-s3.julialang.org/bin/linux/x64/1.9/julia-1.9.4-linux-x86_64.tar.gz` |
| size | `146163887` bytes |
| SHA-256 | `07d20c4c2518833e2265ca0acee15b355463361aa4efdab858dad826cf94325c` |
| runtime | Julia `1.9.4` |
| embedded LLVM | `14.0.6` |
| execution threads | `JULIA_NUM_THREADS=2`; `OMP_NUM_THREADS=2` |

Fresh official `versions.json` repeated the exact URL, size, digest, triplet
`x86_64-linux-gnu`, and detached signature. The official key file at
`https://julialang.org/assets/juliareleases.asc` verified that signature as
good. That verification also exposed a pre-existing provenance error which is
retained rather than averaged away:

* supplied/S6 fingerprint:
  `3673DF529D9075177DF6359B98F1C7EC03961954`;
* fingerprint actually present in the official key and used by the detached
  signature:
  `3673DF529D9049477F76B37566E3C7DC03D6E495`.

The supplied value therefore must not be described as the signing key. Archive
authentication still passes through independent official size/SHA-256
metadata and the good signature by the latter fingerprint.

## Immutable General registry and resolution

The Julia package server returned immutable General tree
`62f696ed0bec9ba90a4c87f781bce51213f0720c`. The exact acquisition chain is:

| field | sealed value |
|---|---|
| requested URL | `https://pkg.julialang.org/registry/23338594-aafe-5451-b93e-139f81909106/62f696ed0bec9ba90a4c87f781bce51213f0720c` |
| effective URL | `https://storage.julialang.net/registry/23338594-aafe-5451-b93e-139f81909106/62f696ed0bec9ba90a4c87f781bce51213f0720c` |
| archive size | `11096061` bytes |
| archive SHA-256 | `b4a9426f7757bbb45dd458cbfdca31f20d62563cce30d08f69ff9af64efeb156` |
| reproduced Git tree | `62f696ed0bec9ba90a4c87f781bce51213f0720c` |
| official General commit | `2c20f8a32f92745902447437e4187ef1926927c5` |
| commit/tree mapping | `https://api.github.com/repos/JuliaRegistries/General/commits/2c20f8a32f92745902447437e4187ef1926927c5` |

The archive was extracted into a fresh workspace-local depot. Initial direct
Git ref attempts were bounded and returned no ref; the package-server route
succeeded with three configured retries. The extracted files reproduce the
advertised tree exactly, and the official GitHub API maps that tree to the
recorded commit. No mutable registry update was used during resolution.

The first resolver attempt failed before solving because the S6 project
declared a package without `src/MUSATargetAdapter.jl`:

```text
ERROR: expected the file `src/MUSATargetAdapter.jl` to exist for package
`MUSATargetAdapter` at `/workspace/contrib/musa/s6-tooling`
```

The smallest successor made it a plain package environment. The requested
exact GPUCompiler `0.26.2` / LLVM.jl `6.1.0` pair then produced the real
compatibility error:

```text
GPUCompiler 0.26.2 is restricted by LLVM 6.1.0 to GPUCompiler 0.21.1-0.23.0;
no versions left
```

General's compat table requires LLVM.jl `6.6.0-6` for GPUCompiler
`0.26.1-0.26.4`. The nearest solution preserving the requested GPUCompiler
0.26 API line is therefore GPUCompiler `0.26.2` / LLVM.jl `6.6.0`. The
alternative preserving LLVM.jl `6.1.0` would regress GPUCompiler to `0.23.0`.
The former was selected and resolved successfully on Julia 1.9.4/LLVM 14.0.6.

The retained [`Manifest.toml`](../../../contrib/musa/s6-tooling/Manifest.toml)
freezes the entire closure. Registry packages with source-tree identities are:

| package | UUID | version | Git tree |
|---|---|---:|---|
| CEnum | `fa961155-64e5-5f13-b03f-caf6b980ea82` | 0.5.0 | `389ad5c84de1ae7cf0e28e381131c98ea87d54fc` |
| ExprTools | `e2ba6199-217a-4e67-a87a-7c52f15ade04` | 0.1.11 | `d2e49e7efd29719d6f28b891b0e0e159daa9d2b4` |
| GPUCompiler | `61eb1bfa-7361-4325-ad38-22787b887f55` | 0.26.2 | `706309c25a6fac3e332b3e436c4077716f266a1f` |
| JLLWrappers | `692b3bcd-3c85-4b1f-b108-f13ce0eb3210` | 1.8.0 | `7204148362dafe5fe6a273f855b8ccbe4df8173e` |
| LLVM | `929cbde3-209d-540e-8aea-75f648917ca0` | 6.6.0 | `ddab4d40513bce53c8e3157825e245224f74fae7` |
| Preferences | `21216c6a-2e73-6563-6e65-726566657250` | 1.5.2 | `8b770b60760d4451834fe79dd483e318eee709c4` |
| Requires | `ae029012-a4dd-5104-9daa-d747884805df` | 1.3.1 | `62389eeff14780bfe55195b7204c0d8738436d64` |
| Scratch | `6c6a2e73-6563-6170-7368-637461726353` | 1.3.0 | `9b81b8393e50b7d4e6d0a9f14e192294d3b7c109` |
| TimerOutputs | `a759f4b9-e2f1-59dc-863e-4aeb61b1ea8f` | 0.5.25 | `3a6f063d690135f5c1ba351412c82bae4d1402bf` |
| LLVMExtra_jll | `dad2f222-ce93-54a1-a47d-0025e8a3acab` | 0.0.29+0 | `88b916503aac4fb7f701bb625cd84ca5dd1677bc` |

All remaining Manifest entries are Julia 1.9.4 standard libraries or their
binary dependencies and retain their exact versions and UUIDs in the file.
Focused API checks confirmed GPUCompiler `0.26.2`, LLVM.jl `6.6.0`, and
`LLVM.version() == v"14.0.6"`.

## Direct Julia-to-MTGPU receipt

[`sealed_direct_route.jl`](../../../contrib/musa/s6-tooling/sealed_direct_route.jl)
uses the real `GPUCompiler.methodinstance`, `CompilerConfig`, `CompilerJob`,
`JuliaContext`, and `compile(:llvm, ...)` APIs. It uses LLVM.jl object APIs to
set the exact triple/layout, convention 102, and `target-cpu=mp_31`; it does not
edit serialized IR. Julia's serializer spells the convention `cc102`. Reading
the same retained bitcode with vendor LLVM14 spells that field
`mtgpu_kernel`, authenticating the shared calling-convention dialect before
backend invocation.

The vendor command was:

```sh
/usr/local/musa/bin/llc -mtriple=mtgpu-mt-musa -mcpu=mp_31 \
  -filetype=obj julia-scalar-mtgpu.bc -o julia-scalar-mp31.o
```

Retained evidence is in
[`evidence/`](../../../contrib/musa/s6-tooling/evidence):

| evidence | SHA-256 |
|---|---|
| genuine Julia LLVM IR | `d9039731dfe190d131cd5fb99298123fe4f9005d70bfb8412e495890521eff04` |
| genuine Julia LLVM bitcode | `58259a1e471b6f98ac2c25ee8e0210af513b8fe1c3a8f548ee5f9578ea586ff1` |
| vendor LLVM14 readback | `0d1cc5d001f8e298e152f9ec432580babafa4b51fdec7a7a8a7995608600d6d4` |
| vendor MTGPU object | `900f21e154fe092b572d30236fee343b3b1898d888a13144ab6537a01b645965` |

The object is ELF64 relocatable with `e_machine` bytes `fd 00` (decimal 253),
the vendor `EM_MTGPU` value. GNU `readelf` mislabels this colliding value as
Synopsys ARCv2.3; this is retained as a host-tool limitation rather than used
as identity evidence. Authenticated vendor `llvm-objdump -f` reports:

```text
file format elf64-mtgpu
architecture: mtgpu
```

Together with vendor readback containing `mtgpu_kernel` and
`"target-cpu"="mp_31"`, this is authentic `EM_MTGPU`/`mp_31` evidence. It is
not evidence that the object was loaded or executed.

## Fail-loud guards and verification

The accepted S5 adapter and its 42-check test file are byte-unchanged. The S6R1
route independently rejects before vendor invocation:

* a Julia or LLVM major other than the sealed Julia 1.9.4/LLVM 14 denominator;
* host `swiftcc`, Julia GC state, safepoints/PTLS, and host runtime declarations;
* any address space other than generic space 0;
* a wrong triple, data layout, convention, CPU, or non-kernel entry;
* any device-library input or attempt to enter GPUCompiler library linking;
* an absent vendor tool, missing vendor `mtgpu_kernel` readback, or non-MTGPU
  object identity; and
* every pre-existing evidence path, preventing overwrite.

Executed with two Julia/OMP threads:

* sealed manifest resolve, instantiate, import, and precompile: PASS;
* focused API/scalar-codegen checks: PASS, 10/10;
* mutation-sensitive ABI/version/library checks: PASS, 11/11;
* retained evidence re-verification: PASS, including all three content hashes,
  `EM_MTGPU`, and `mp_31`;
* S5 source/test preservation check: PASS (no diff);
* `git diff --check`: PASS; and
* `make fix-whitespace`: executed with the authenticated task-local Julia and
  exited 2 only for the two accepted S1 review tabs at lines 52 and 58, exactly
  as recorded by S5.

No host install, credentials, services, database, cleanup, deletion, move,
rename, push, deploy, GPU access, or formal acceptance was performed.
