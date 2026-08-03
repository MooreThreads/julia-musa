# MUSA S4 build-frontier independent review

## Disposition

This receipt independently reviews Gluon task
`5d5b1667-6faa-4fe5-a243-44885088a368`, attempt
`1c6f1a14-6518-425d-9dea-70bba35218aa`, and candidate
`7d3fe37e-e33a-4ec1-a483-997ff3cc8397` from the exact candidate result:

```text
commit  a6131d7fb29a2ccba97484226ccbb6447d2c2839
tree    2a1d50d69592f56b50df70245787e0cb5a470021
parent  1559e5f2d03fc887d29966f1dd15dde85cb5cc48
subject doc: Record MUSA signed-package build frontier
```

**NO_GO for Julia-to-MUSA code generation. PASS for official dependency
authentication and the clean workspace-local MUSA `mp_31` control.** The
first retained blocker is a concrete LLVM dialect boundary: Julia 1.12.6
emits LLVM 18 IR, while MUSA 5.2.0 supplies an LLVM 14 MTGPU backend. The
backend first rejects opaque `ptr`; its compatibility flag advances parsing
and then rejects LLVM 18 `memory(...)` attributes. This is not a missing
credential, optional-metadata requirement, host-path accident, or GPU gate.

Technical completion of this independent receipt is not formal acceptance.

| Required result | Independent result |
|---|---|
| Exact S4 base and clean start | PASS |
| Official Julia identity | PASS |
| Official vendor repository and package identities | PASS |
| Clean workspace-local MUSA path | PASS |
| Representative `mp_31` vendor compile/link | PASS |
| Julia-emitted IR | PASS |
| Julia IR accepted by the vendor MTGPU backend | NO_GO |
| GPU execution | NOT RUN, as required |

The attempt and candidate UUIDs are orchestration labels supplied by the
review task. No additional workspace metadata maps those labels, and none is
needed: the immutable commit, tree, and parent above identify the reviewed
candidate. Unavailable optional metadata was not treated as a gate.

## Independent identity chain

The predecessor's ignored artifacts were absent, so none of its retained
objects or logs was reused. Fresh review inputs were acquired below ignored,
task-specific roots:

```text
deps/srccache/gluon-f6e2abf7-s4-review
usr/gluon-f6e2abf7-s4-review
```

### Julia

The official Julia 1.12.6 Linux x86-64 archive, checksum list, detached
signature, and release key were fetched from `julialang-s3.julialang.org`
and `julialang.org`. The archive identity was independently established by
both the published checksum and detached signature:

```text
289794236  bbabf3bef19421a9dbd24a767d807606ab85e444323b5a1c73ffe293fa3d079a  julia-1.12.6-linux-x86_64.tar.gz
833        739c2a114eefa0004675232f9288f0061a91b1d6daba3730245903482d643cf1  julia-1.12.6-linux-x86_64.tar.gz.asc
1309       d44a6138f428b7a4cd4d4e6d0aba53bbf380d3279e575bfb743f668b7f88190f  julia-1.12.6.sha256
3112       a27705bf1e5a44d1905e669da0c990ac2d7ab7c13ec299e15bacdab5dcbb8d13  juliareleases.asc
```

The archive digest exactly matched `julia-1.12.6.sha256`. Fresh-local-keyring
verification returned `GOODSIG` and `VALIDSIG` for:

```text
3673DF529D9049477F76B37566E3C7DC03D6E495
Julia (Binary signing key) <buildbot@julialang.org>
```

The extracted executable has SHA-256
`fd670aabc838e93f178cbcf7304c5e9c50aadcce3735e86d5e3218b1bb04e602`
and reported:

```text
julia version 1.12.6
commit=15346901f0039751c5488744f1f62de7d87510a8
llvm=18.1.7
threads=2
```

The checkout itself pins LLVM `21.1.8`, branch and SHA
`julia-21.1.8-0`, in `deps/llvm.version`. There is no tracked non-documentation
MUSA, MTGPU, Moore Threads, or MThreads caller in this tree.

### MUSA

The vendor repository configuration package came from the Moore Threads
Ubuntu 22.04 repository. It has size 3,288 and SHA-256
`09577a0c1d613753e82e972e34c222a1c7bdcc0b444bb23ad71ae395e8ba61be`.
Its extracted keyring identifies:

```text
5C804CAE420AFCC0BDD28FECEE9B8BE860C98FEF
musatools <developers@mthreads.com>
```

`gpgv` returned `Good signature` for the vendor `Release`, signed on
2026-07-09. The independently fetched metadata identities were:

```text
2692   043a3d9bd8d6a35386ddc0821cf0f21998a3f95391ece656e2113ac65e9a2644  Release
821    1f11972ad8adb25721fb541e3e122131fdea16c05ba52b26b92dfb198151c36d  Release.gpg
17085  f70967631c6376e3d4f429fc510db2ff31c787b11cd390c4804f35fc39bdcb8e  Packages.gz
```

The signed `Release` contains that exact SHA-256 and size for
`main/binary-amd64/Packages.gz`. The four downloaded package identities then
matched their records in that authenticated index:

| Package | Version | Size | SHA-256 |
|---|---:|---:|---|
| `mtcc-5-2` | 5.2.0 | 1,079,535,774 | `22a37d7af78ea5bd25e72b7d9549bb02a2512c852617c2e87ecf6a27b5d242d1` |
| `musa-musart-5-2` | 5.2.0 | 338,792 | `ba3e3a4f52b68602382f81542625f544ed65cc0fe3f9cb64e655b1167ac34a5f` |
| `musa-musart-dev-5-2` | 5.2.0 | 7,436,708 | `7e235c9efc2d85adcc752870cdc955af77c3591ed767ec6775d942ef21408bdf` |
| `musa-toolkit-5-2-config-common` | 5.2.0 | 1,292 | `919fc728192df8cb1f12f99f91e38091bc7fc8ae3d664002e4010d4fe93216bd` |

Their non-directory payload paths had no collisions before extraction. They
were extracted, not installed, beneath the fresh review prefix. The accepted
tool path was exactly:

```text
/workspace/usr/gluon-f6e2abf7-s4-review/musa/root/usr/local/musa-5.2
```

With inherited `MUSA_HOME` and `LD_LIBRARY_PATH` unset, `mcc --version`
reported MUSA 5.2.0, Clang 14.0.0, commit
`8a8cb2971e3084fc442baeacb7447e3d73263dc8`, and that workspace-local
installation directory. `llvm-config` reported `14.0.0` and targets
`X86 MTGPU`. Key extracted hashes exactly matched S4:

```text
3ee68f6b874f0ddd4b625917490e7fffcfaa189b205b690191a3e354c212f102  bin/clang-14
31f6e308efb76d3194ef0a3ab6ea2fa2c4b2d39af432d1b998e1fe56e9923c2c  bin/llc
d0af9bb6d1132157ed75c52bf7e98ee575540e9a903c6deef79d208cb848ee00  bin/lld
7434f3a9a5a9260915b3980bf988fbbf76d2f4c2ad16e5beb97ac6cd10cb262f  bin/clang-offload-bundler
bc0b583e5998ed1767150fcaa42658df3053402521f37d5a85957079178ff353  lib/libmusart.so.5.2.0
e22ae18cbb72b442096bbac4341486a860df368b480a7461b2907dc2c28242ff  mtgpu/bitcode/libdevice.bc
4178322ac7b45cd1f1e20ee055aed17c529cab17fcb3fe886dad8fc6b554401d  lib/clang/14.0.0/lib/linux/trap_handler.o
```

One initial version-probe harness expression searched only regular files and
therefore missed that `bin/mcc` is a symlink to `clang`. It exited before
invoking the compiler. Resolving the known clean prefix corrected the probe;
this procedural locator mistake is not counted as a compiler result.

## CPU-only build and parser probes

Every compile ran with `OMP_NUM_THREADS=2`; Julia ran with `-t2`. No GPU,
driver, device enumeration, or runtime execution was used.

### Vendor `mp_31` control

The independent control was a bounds-checked `UInt32` kernel implementing
`out[i] = 3U * x[i] + y[i]`. The operative command was:

```text
env -u MUSA_HOME -u LD_LIBRARY_PATH OMP_NUM_THREADS=2 \
  <local-musa>/bin/mcc --musa-path-ignore-env \
  --musa-path=<local-musa> -x musa --offload-arch=mp_31 \
  --musa-device-obj-only -c kernel.mu -o kernel-carrier.o
```

It exited 0. The independent `-###` trace selected the local `libdevice.bc`,
`lld`, `trap_handler.o`, offload bundler, `mtgpu-mt-musa`, and
`target-cpu=mp_31`. A scan for the inherited host prefix `/usr/local/musa/`
had no match. Bundle listing returned exactly:

```text
musa-mtgpu-mt-musa-mp_31
host-x86_64-unknown-linux-gnu
```

The fresh carrier SHA-256 is
`c7b02408aa7944b7a335a67146c506721f890bb65e94da4ad7025abd845e81b6`.
The unbundled device image SHA-256 is
`67cf417a1e330a7234c17eae9155bcfbca341f341a2acb02d512036213401e33`;
vendor `llvm-readelf -h` reports:

```text
Class:   ELF64
Type:    DYN (Shared object file)
Machine: EM_MTGPU
```

The fresh object hashes need not equal S4 because this independent kernel's
source text and task path differ. The target, bundle identities, device
machine, and clean driver closure reproduce the claimed vendor frontier.

### Julia emission and vendor parser

The authenticated Julia emitted an optimized module for the pure method
`UInt32(3) * x + y` using:

```text
OMP_NUM_THREADS=2 <julia> --startup-file=no --history-file=no -t2 -e \
  'using InteractiveUtils; saxpy(x::UInt32, y::UInt32) = UInt32(3) * x + y;
   code_llvm(stdout, saxpy, Tuple{UInt32, UInt32};
             raw=true, dump_module=true, optimize=true)'
```

The fresh IR SHA-256 is
`3bc0b516d903f4d9d4fb503dc1e1dc8dea856ae2214929de304bfda86cfcb649`.
It concretely contains the x86-64 host triple, Julia `swiftcc`, opaque `ptr`,
GC-stack and safepoint operations, and LLVM 18 `memory(...)` attributes.

Submitting that unmodified module to the vendor backend gave the minimal
two-step parser result:

```text
<local-musa>/bin/llc -mtriple=mtgpu-mt-musa -mcpu=mp_31 \
  -filetype=obj julia-saxpy.ll
exit 1: ptr type is only supported in -opaque-pointers mode
        error: expected type

<local-musa>/bin/llc -opaque-pointers -mtriple=mtgpu-mt-musa \
  -mcpu=mp_31 -filetype=obj julia-saxpy.ll
exit 1 at:
attributes #2 = { mustprogress nounwind willreturn memory(read, inaccessiblemem: readwrite) }
                                                   ^
error: unterminated attribute group
```

The second probe is important: the vendor-provided opaque-pointer switch
removes the first syntax gate and exposes the next LLVM-version incompatibility.
Together with the successful vendor object control, this proves that the
failure is a real Julia-to-MUSA IR dialect/ABI boundary rather than a broken
package identity, missing MUSA header, wrong driver path, unavailable optional
metadata, or absent GPU.

Parsing is only the first boundary. The emitted module also carries a host
triple, Julia calling convention, GC state, safepoints, runtime declarations,
and no MUSA kernel annotations, address-space policy, device-library policy,
or launch ABI. Textually rewriting the two parser errors would therefore not
constitute a Julia-to-MUSA compiler integration.

## Smallest maintainable successor

The bounded successor is an out-of-tree, version-gated Julia/GPUCompiler MUSA
target adapter paired with a vendor-supported MTGPU backend that accepts the
Julia checkout's LLVM dialect. Its first slice should contain only:

1. an `mtgpu-mt-musa` target definition with explicit data layout, `mp_31`
   CPU, address spaces, and device-library selection;
2. a device-only kernel ABI lowering that removes Julia host ABI, GC, and
   safepoint dependencies and attaches the vendor kernel convention and
   annotations; and
3. this CPU-only scalar kernel as a contract test from Julia method through
   MTGPU object emission and `EM_MTGPU` inspection.

The backend compatibility must be explicit and supported: preferably an MTGPU
backend rebased to Julia's pinned LLVM 21.1.8, or a vendor-maintained bridge
with a documented Julia-facing IR and ABI contract. Replacing Julia's LLVM
with the proprietary LLVM 14 fork or maintaining a textual LLVM 18-to-14
rewriter is not the bounded successor.

## Scope and verification

Only this review receipt is tracked. No production or test source changed.
No host installation, credentials, services, databases, cleanup, deletion,
move, rename, overwrite, push, deploy, formal acceptance, or GPU access
occurred. Fresh ignored evidence remains under the task-specific roots.

Required checks and results:

* exact base and clean starting worktree: PASS;
* `make fix-whitespace`: executed with the authenticated Julia and exited 2
  only on the two accepted predecessor tabs at
  `musa-s1-metadata-inventory-correction-independent-review.md:52` and `:58`;
* Julia checksum and detached signature: PASS;
* vendor `Release.gpg`, signed index binding, and four package hashes: PASS;
* workspace-local path and inherited-host-path exclusion: PASS;
* vendor `mp_31` compile, bundle, and `EM_MTGPU` inspection: PASS;
* independent Julia IR emission with two threads: PASS;
* Julia IR through vendor LLVM 14 MTGPU `llc`: NO_GO at the concrete dialect
  errors above;
* GPU execution: not run, as required;
* technical success of this receipt: not formal acceptance.
