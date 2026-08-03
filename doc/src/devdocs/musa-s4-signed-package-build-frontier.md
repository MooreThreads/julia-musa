# MUSA S4 signed-package build-frontier receipt

## Decision

This receipt was produced by Gluon task
`5d5b1667-6faa-4fe5-a243-44885088a368` from exact accepted S3
independent-review result `1559e5f2d03fc887d29966f1dd15dde85cb5cc48`.

**NO_GO for Julia-to-MUSA code generation; PASS for authenticated dependency
acquisition and the workspace-local vendor baseline.** The signed vendor APT
channel is sufficient authority for this implementation slice, as explicitly
authorized by the task. No monolithic offline archive or per-file distribution
manifest was required or sought.

| Required result | Result | Evidence |
|---|---|---|
| Official Julia available locally | PASS | Julia 1.12.6 archive checksum and detached signature verified; executable reports `julia version 1.12.6`. |
| Exact required MUSA 5.2.0 components available locally | PASS | Detached vendor signature authenticates `Release`; its SHA-256 entry binds `Packages.gz`; all four downloaded package digests match that index. |
| Source-format gate executed | FAIL | The checker ran and reported the same two literal tabs embedded in accepted S1 review evidence. It made no tracked edit. |
| Workspace-local MUSA compiler/link baseline | PASS | `mcc` compiled and linked the representative kernel for `mp_31`; the extracted image is ELF64 `EM_MTGPU`. |
| Julia IR through the vendor MTGPU backend | NO_GO | Vendor LLVM 14 first rejects opaque pointers, then with `-opaque-pointers` rejects LLVM 18 `memory(...)` attribute syntax. The checkout itself pins LLVM 21.1.8. |

The exact next blocker is an LLVM-dialect-compatible Julia MUSA compiler
adapter/backend. This checkout has no MUSA target caller, and vendor LLVM 14
cannot parse the IR dialect emitted by the authenticated Julia 1.12.6
bootstrap. Replacing Julia's pinned LLVM 21.1.8 with the proprietary LLVM 14
fork, or mechanically rewriting IR and inventing a MUSA ABI, would be a broad
unsupported change rather than a bounded response to a Julia production-source
compile defect. No production source was changed.

All compilation was CPU-only with `OMP_NUM_THREADS=2`; Julia used two threads.
No GPU, driver or device query, host package installation, credentials,
service, database, cleanup, deletion, move, rename, push, deploy, or formal
review occurred. Technical completion is not formal acceptance.

## Accepted source and immediate callers

The task began clean and detached at:

```text
commit 1559e5f2d03fc887d29966f1dd15dde85cb5cc48
tree   d06fbd83cd40f9eb56b3308da615c253a556b7b0
parent 2c2197f65b100f90b41da894b9d7f62bf1e68962
```

The accepted S3 subject and review and the immediate format/build inputs were
read in full. Their SHA-256 identities were:

```text
cbad43803ed0cfcf6e650e0a2fc21234a40ddf1d67ee68a1df7cfbc5f1ea5378  doc/src/devdocs/musa-s3-authorized-dependency-acquisition.md
14de171710b1ad0f8e68f71f0ab4f414e704707d43c31be97d5f4869d3be41fe  doc/src/devdocs/reviews/musa-s3-authorized-dependency-acquisition-independent-review.md
67748745dc1cdfc14f370c7be0266cdc3d32386d3b9ebafec2e47d9f58ce5d61  VERSION
8f8a6c499bc4fd4023f5db7a3a44ee6ca56957e09869cc2bc3272b2a4bff3d06  Makefile
312605c6fefeed042d0dc74b5d7d7f53c68d56bce86ce2c28e3054d3af0d743c  Make.inc
a6c913345e39138ebcdf71d5ea23e92917fe0bdf3d1397e81d62c439f4e915a9  contrib/check-whitespace.jl
```

`VERSION` is `1.14.0-DEV`, and `deps/llvm.version` pins LLVM `21.1.8` at
`julia-21.1.8-0`. There is no built `usr/bin/julia`. A tracked search for
`MUSA.jl`, MUSA package/caller names, `MTGPU`, MThreads, and Moore Threads
found documentation receipts only: no production, package, test, or build
caller exists in this checkout. Therefore the smallest real frontier is the
vendor-native control followed by Julia-emitted LLVM IR submitted to the
vendor MTGPU backend.

## Official Julia acquisition and verification

The exact accepted S3 bootstrap version, official Julia 1.12.6 for Linux
x86-64, was fetched under the fresh ignored root
`deps/srccache/gluon-5d5b1667-s4/julia` and extracted under
`usr/gluon-5d5b1667-s4/julia`. The source URLs were:

```text
https://julialang-s3.julialang.org/bin/checksums/julia-1.12.6.sha256
https://julialang-s3.julialang.org/bin/linux/x64/1.12/julia-1.12.6-linux-x86_64.tar.gz
https://julialang-s3.julialang.org/bin/linux/x64/1.12/julia-1.12.6-linux-x86_64.tar.gz.asc
https://julialang.org/assets/juliareleases.asc
```

The retained bytes have these sizes and SHA-256 values:

```text
289794236  bbabf3bef19421a9dbd24a767d807606ab85e444323b5a1c73ffe293fa3d079a  julia-1.12.6-linux-x86_64.tar.gz
833        739c2a114eefa0004675232f9288f0061a91b1d6daba3730245903482d643cf1  julia-1.12.6-linux-x86_64.tar.gz.asc
1309       d44a6138f428b7a4cd4d4e6d0aba53bbf380d3279e575bfb743f668b7f88190f  julia-1.12.6.sha256
3112       a27705bf1e5a44d1905e669da0c990ac2d7ab7c13ec299e15bacdab5dcbb8d13  juliareleases.asc
```

The archive digest exactly matches the official checksum list. Verification
in a fresh local GPG home returned `GOODSIG` and `VALIDSIG` for fingerprint
`3673DF529D9049477F76B37566E3C7DC03D6E495` and identity
`Julia (Binary signing key) <buildbot@julialang.org>`. The extracted executable
has SHA-256
`fd670aabc838e93f178cbcf7304c5e9c50aadcce3735e86d5e3218b1bb04e602`,
reports `julia version 1.12.6`, and reports official commit `15346901f00` with
LLVM `18.1.7`.

The essential commands were:

```text
curl --fail --location --max-redirs 3 --proto '=https' --tlsv1.2 <URL> -o <fresh-path>
sha256sum julia-1.12.6-linux-x86_64.tar.gz
gpg --homedir <fresh-local-gnupg> --batch --import juliareleases.asc
gpg --homedir <fresh-local-gnupg> --batch --status-fd 1 --verify <signature> <archive>
tar -xzf <verified-archive> -C usr/gluon-5d5b1667-s4/julia
usr/gluon-5d5b1667-s4/julia/julia-1.12.6/bin/julia --version
```

## Authenticated MUSA component acquisition

The vendor repository configuration package was fetched from:

```text
https://dl.mthreads.com/repo/repository/ubuntu2204/pool/jammy/amd64/musa-repo-jammy_1.0.0.11-1_all.deb
```

It is 3,288 bytes with SHA-256
`09577a0c1d613753e82e972e34c222a1c7bdcc0b444bb23ad71ae395e8ba61be`.
Its extracted keyring identifies `musatools <developers@mthreads.com>` with
primary fingerprint `5C804CAE420AFCC0BDD28FECEE9B8BE860C98FEF`.

The authenticated metadata URLs and identities were:

```text
https://dl.mthreads.com/repo/repository/ubuntu2204/dists/jammy/Release
2692   043a3d9bd8d6a35386ddc0821cf0f21998a3f95391ece656e2113ac65e9a2644
https://dl.mthreads.com/repo/repository/ubuntu2204/dists/jammy/Release.gpg
821    1f11972ad8adb25721fb541e3e122131fdea16c05ba52b26b92dfb198151c36d
https://dl.mthreads.com/repo/repository/ubuntu2204/dists/jammy/main/binary-amd64/Packages.gz
17085  f70967631c6376e3d4f429fc510db2ff31c787b11cd390c4804f35fc39bdcb8e
```

`gpgv --keyring <extracted-vendor-keyring> Release.gpg Release` exited 0 with
`Good signature`. The signed `Release` records the exact observed
`Packages.gz` size and SHA-256. Four packages, and only these four, were needed
for the clean-room compiler/header/runtime closure:

| Package | Version | Size | Published and observed SHA-256 |
|---|---:|---:|---|
| `mtcc-5-2` | 5.2.0 | 1,079,535,774 | `22a37d7af78ea5bd25e72b7d9549bb02a2512c852617c2e87ecf6a27b5d242d1` |
| `musa-musart-5-2` | 5.2.0 | 338,792 | `ba3e3a4f52b68602382f81542625f544ed65cc0fe3f9cb64e655b1167ac34a5f` |
| `musa-musart-dev-5-2` | 5.2.0 | 7,436,708 | `7e235c9efc2d85adcc752870cdc955af77c3591ed767ec6775d942ef21408bdf` |
| `musa-toolkit-5-2-config-common` | 5.2.0 | 1,292 | `919fc728192df8cb1f12f99f91e38091bc7fc8ae3d664002e4010d4fe93216bd` |

Each package was fetched from its `Filename` under
`https://dl.mthreads.com/repo/repository/ubuntu2204/`, checked against the
signed index, and extracted with `dpkg-deb -x` beneath the fresh prefix
`usr/gluon-5d5b1667-s4/musa/root`. Nothing was installed on the host. The
compiler reports Clang 14.0.0, `mcc` 5.2.0, commit
`8a8cb2971e3084fc442baeacb7447e3d73263dc8`, and its workspace-local
installation directory. `llvm-config` reports 14.0.0 and targets `X86 MTGPU`.

The final relevant extracted payload hashes are:

```text
3ee68f6b874f0ddd4b625917490e7fffcfaa189b205b690191a3e354c212f102  bin/clang-14
31f6e308efb76d3194ef0a3ab6ea2fa2c4b2d39af432d1b998e1fe56e9923c2c  bin/llc
d0af9bb6d1132157ed75c52bf7e98ee575540e9a903c6deef79d208cb848ee00  bin/lld
7434f3a9a5a9260915b3980bf988fbbf76d2f4c2ad16e5beb97ac6cd10cb262f  bin/clang-offload-bundler
bc0b583e5998ed1767150fcaa42658df3053402521f37d5a85957079178ff353  lib/libmusart.so.5.2.0
e22ae18cbb72b442096bbac4341486a860df368b480a7461b2907dc2c28242ff  mtgpu/bitcode/libdevice.bc
4178322ac7b45cd1f1e20ee055aed17c529cab17fcb3fe886dad8fc6b554401d  lib/clang/14.0.0/lib/linux/trap_handler.o
```

An initial frontend control succeeded while the inherited environment exposed
host `MUSA_HOME=/usr/local/musa`; that result was rejected as contaminated.
After explicitly unsetting `MUSA_HOME` and `LD_LIBRARY_PATH`, the minimal
three-package closure correctly failed with `cannot find MUSA headers`. This
concrete failure justified adding only `musa-musart-dev-5-2`. The accepted
rerun additionally used `--musa-path-ignore-env` and the exact workspace-local
`--musa-path`. Its `-###` trace contains no `/usr/local/musa/` reference.

## Format gate and build frontier

The source-format command was:

```text
env PATH="<verified-julia>/bin:$PATH" OMP_NUM_THREADS=2 MAKEFLAGS=-j2 make fix-whitespace
```

It reached the Julia checker, which reported:

```text
Whitespace check found 2 issues:
doc/src/devdocs/reviews/musa-s1-metadata-inventory-correction-independent-review.md:52 -- tab
doc/src/devdocs/reviews/musa-s1-metadata-inventory-correction-independent-review.md:58 -- tab
make: *** [Makefile:185: fix-whitespace] Error 1
```

The outer command exited 2. These are the same two literal tabs in fenced
accepted predecessor output established by S3; the fixer does not alter them.
The tracked diff stayed empty and `git diff --check` exited 0.

The representative vendor control was a bounds-checked `UInt32` kernel
computing `out[i] = 3U * x[i] + y[i]`. With the inherited MUSA variables
unset, its accepted build command was equivalent to:

```text
env -u MUSA_HOME -u LD_LIBRARY_PATH OMP_NUM_THREADS=2 \
  <local-musa>/bin/mcc --musa-path-ignore-env --musa-path=<local-musa> \
  -x musa --offload-arch=mp_31 --musa-device-obj-only -c kernel.mu \
  -o kernel-carrier.o
```

It exited 0. The driver selected the local `libdevice.bc`, MTGPU `mp_31`,
local `lld`, local `trap_handler.o`, and local offload bundler. Bundle listing
returned exactly:

```text
musa-mtgpu-mt-musa-mp_31
host-x86_64-unknown-linux-gnu
```

The carrier SHA-256 is
`1171a4228e504352655fee579d6360cae13d4796fdb522812548c69e1cf165a8`.
The extracted device image SHA-256 is
`e6d6f6b9c60aeab4139e5d7af6f9e05635c60d82ca76dae1e70e15928917cb79`;
vendor `llvm-readelf` reports ELF64 DYN and machine `EM_MTGPU`. This is a
compile/link baseline only, not GPU execution or Julia integration success.

For the Julia-facing slice, Julia 1.12.6 emitted optimized module IR for a
pure `UInt32(3) * x + y` method. The module identifies the x86-64 host triple,
Julia `swiftcc` ABI, opaque `ptr`, GC/safepoint operations, and LLVM 18
attributes. Its SHA-256 is
`f5697a5c882bac47e3ea39015fb5b68418e2c1aee158e44ad441f07b2a3b06f9`.
Submitting it to the real vendor backend with:

```text
<local-musa>/bin/llc -mtriple=mtgpu-mt-musa -mcpu=mp_31 -filetype=obj julia-saxpy.ll
```

exited 1 at the first opaque `ptr` with `expected type`. Adding the vendor
LLVM 14 compatibility flag `-opaque-pointers` advanced parsing, then exited 1
at the LLVM 18 attribute:

```text
attributes #2 = { mustprogress nounwind willreturn memory(read, inaccessiblemem: readwrite) }
                                                   ^
error: unterminated attribute group
```

This is the retained first real Julia/MUSA compiler blocker. Even a parser
rewrite would leave the host Julia ABI, GC, safepoints, target intrinsics,
kernel calling convention, address spaces, device libraries, and annotations
without a MUSA lowering owner. No production edit is justified at this point.

## Changed files, checks, and retained evidence

The sole tracked change is this S4 receipt. There are no production or test
changes. Fetched packages, extracted prefixes, HTTP headers, compiler traces,
IR, objects, and logs remain under ignored task-specific `deps/srccache` and
`usr` roots.

Executed checks and outcomes:

* source-format gate: executed, outer exit 2 on the two accepted predecessor
  tabs;
* official checksum comparison and detached Julia signature: PASS;
* detached vendor `Release.gpg` verification and signed `Packages.gz` binding:
  PASS;
* all four component package checksum comparisons: PASS;
* clean-room vendor `mcc` compile/link/bundle and `EM_MTGPU` inspection: PASS;
* inherited host MUSA-path scan of the accepted driver trace: PASS, no match;
* Julia LLVM 18 IR to vendor MTGPU LLVM 14 backend: NO_GO with the exact parser
  errors above;
* `git diff --check`: PASS;
* GPU/runtime execution: not requested and not performed.

The smallest successor is a maintained Julia/GPUCompiler MUSA target adapter
paired with an MTGPU backend that accepts the checkout's LLVM 21.1.8 dialect,
or a vendor-supported compatibility bridge with an explicit Julia-facing ABI.
It should rerun this same CPU-only kernel frontier before any GPU execution.
