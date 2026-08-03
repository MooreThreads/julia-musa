# Independent review of the MUSA S2 full metadata gate

## Scope and result

This receipt was produced by Gluon task
`27051446-b612-480b-bc6c-8b9428713455`. It independently reviews task
`caa2b3c4-68ba-49a0-a19d-d6b88de9c256`, attempt
`6ac39bb3-2cb1-4408-915a-031ab31de33d`, candidate
`52594af0-56fa-45e5-8623-eab40cf8e4fb`, and its exact committed result
`c06132f181a7abbf7200bcd4f6e6744b15d81e8f`.

**NO_GO for implementation or readiness.** The S2 accounting is internally
complete and independently reproducible, but its first applicable failure is
T02. Neither the declared installed MUSA tree nor the tracked offline Julia
tree contains an authoritative complete MUSA 5.2.0 distribution archive,
vendor checksum and signature, or authoritative complete distribution
manifest. Package names, an installed directory, component files, and partial
manifest-name matches are not substitutes. This is a demonstrated metadata
failure, not an environment-induced inconclusive result.

The operator reported paging all 17,272 persisted events in 18 pages through
`next_cursor=null`. That event corpus is identified here for provenance; this
independent receipt authenticates the immutable committed result and the
locally replayable evidence rather than claiming a second event-service query.
The accepted R0 and S1 receipts and the sole S2 receipt were read in full.

All commands were CPU-only with `OMP_NUM_THREADS=2` and `MAKEFLAGS=-j2`. No
network, fetch, installation, package manager, credentials, service, database,
driver or device query, GPU access or runtime, cleanup, deletion, formal
decision action, push, or deployment was used. Technical completion of this
review is not formal acceptance.

## Exact lineage and write-set authentication

The review began with an empty worktree at detached `HEAD`
`c06132f181a7abbf7200bcd4f6e6744b15d81e8f`, tree
`65b114f927bc2521cc1c7c294001f373500d87ac`. Its commit object has exactly one
parent, accepted S1 review result
`228dab02283d62c0f4c1429d649dbe1bd9ad5b3e`, tree
`35655e55fb92baf6f9e2ce57113ee6f261703d31`. The local accepted chain is:

```text
cc2f404a962ed06520a5e73493e5b84217bbf6f5
 -> 6c474d935ecf54e880411638811aace4e1220a26  R0 subject
 -> a380e087cf97e6b658c6d30129290c08fc42b787  accepted R0 review
 -> df891bdc2a9675e872c94c3bab86c6bff6afe5a9  repaired S1 subject
 -> 228dab02283d62c0f4c1429d649dbe1bd9ad5b3e  accepted S1 review
 -> c06132f181a7abbf7200bcd4f6e6744b15d81e8f  S2 subject
```

The raw parent-to-subject diff is exactly one add-only mode-100644 record:

```text
:000000 100644 0000000000000000000000000000000000000000 f3d1894c6d317129b406fb65b37375c7869b6d2c A doc/src/devdocs/musa-s2-metadata-gate-evidence.md
```

`git diff --check` over that range was empty. There are no production, test,
build-system, package, or existing-document changes. A tracked search outside
all MUSA receipts for `MUSA.jl`, MUSA package/caller names, `MTGPU`, MThreads,
and Moore Threads exited 1 with no output. The only relevant Julia sources
remain the target-neutral seams in `base/genericmemory.jl` and
`src/aotcompile.cpp`; `deps/llvm.version` pins LLVM 21.1.8 and `deps/llvm.mk`
has the target list `host;NVPTX;AMDGPU;WebAssembly;BPF;AVR`. Therefore the
subject neither changes nor establishes a production MUSA caller.

The SHA-256 identities of the read receipts were:

```text
863f4966e755afdec8e6b45a135d5e57ee69063e51c4edce105284e02cf434ad  doc/src/devdocs/musa-porting-research.md
9f3c36bb80c43a14b0e76736468c01eca1e3a6a5656353b39336b5f18ff08677  doc/src/devdocs/musa-porting-research-independent-review.md
a89f3d4d8171a4e3049681376b35ca84617d36174e9d85c647ad1eb65afb8900  doc/src/devdocs/musa-s1-metadata-inventory.md
da1e413a4983b580ac6c5580aeb4ff9214a99b8e02741905716e20344d2cc222  doc/src/devdocs/reviews/musa-s1-metadata-inventory-correction-independent-review.md
6ae8a3515fac538136d7bb50569a259f3e948ee7e8a09a8675a956416acd8c2a  doc/src/devdocs/musa-s2-metadata-gate-evidence.md
```

## Independent 40-field reconstruction

The human table was parsed independently of the embedded executable block.
It contains the exact ordered ID set T01–T10, A01–A15, P01–P08, L01–L04, and
O01–O03: 40 rows. Recalculation gives **P=11, F=27, S=0, I=0, N=2**. Excluding
only O02 and O03 leaves exactly 38 applicable rows. Compared with accepted S1
(`P=8, F=30, N=2`), only T08, A05, and A06 move from F to P.

| ID | Independently reconstructed requirement | Result |
|---|---|---|
| T01 | toolkit 5.2.0 identity and commits | P |
| T02 | original archive, vendor signature/checksum, complete manifest | F, first blocker |
| T03 | supported host OS and architectures | F |
| T04 | complete immutable offline layout | F |
| T05 | compiler identity and hash | P |
| T06 | assembler/linker identities and hashes | P |
| T07 | runtime identity, hash, and API version | P |
| T08 | three device-library hashes | P |
| T09 | driver ABI/version matrix | F |
| T10 | device/firmware inventory and ISA matrix | F |
| A01 | vendor LLVM version and backend | P |
| A02 | Julia LLVM version and target list | P |
| A03 | vendor-to-Julia LLVM compatibility bridge | F |
| A04 | accepted input IR/object formats | F |
| A05 | exact device target triple | P |
| A06 | exact data layout | P |
| A07 | ISA ID to device mapping | F |
| A08 | exact code-object/fatbin ABI | F |
| A09 | kernel calling convention | P |
| A10 | address-space numbers and semantics | F |
| A11 | intrinsic and device-library ABI | F |
| A12 | device-library selection and link order | F |
| A13 | atomics and synchronization semantics | F |
| A14 | exception, error, and debug ABI | F |
| A15 | runtime/driver ABI compatibility | F |
| P01 | maintained Julia MUSA repository | F |
| P02 | exact package commit | F |
| P03 | package owner and maintenance evidence | F |
| P04 | Julia compatibility bounds | F |
| P05 | GPUCompiler compatibility bounds | F |
| P06 | LLVM.jl compatibility bounds | F |
| P07 | Project, Manifest, registry, and artifact hashes | F |
| P08 | package test matrix and provenance | F |
| L01 | exact vendor license agreement | F |
| L02 | redistribution permission or consent | F |
| L03 | per-component license mapping | F |
| L04 | third-party notices beyond LLVM | F |
| O01 | separated Julia/GPUCompiler/external ownership | P |
| O02 | Julia-core source change in S2 | N |
| O03 | runtime or GPU result | N |

The independently derived membership sets are:

```text
P=T01,T05,T06,T07,T08,A01,A02,A05,A06,A09,O01
F=T02,T03,T04,T09,T10,A03,A04,A07,A08,A10,A11,A12,A13,A14,A15,P01,P02,P03,P04,P05,P06,P07,P08,L01,L02,L03,L04
N=O02,O03
```

T01 passes first on the installed version identity. T02 is the next ordered
row and fails, so it is exactly the first blocker; later observations cannot
bypass it.

## Local authority and absence replay

Direct SHA-256 replay matched every identity used by the S2 gate:

```text
0cb715b308fb3d4abcd89f79a0980714db2b048c562cf9bf688a664340382901  version.json
02917d706f27a1c0d83f8223ab1d03789462d703bf11580d5d57204d27a64d13  install.sh
324ecf556193490f881c9c5389776129d5aafd80d1856210137593886866ab06  bin/clang-14
042c88d4b851584d684aebacca5fed151a9fd37df35b588cc1f4a37b22dbce83  bin/mtxas
e9f15c65f47a74064af902dd9a02c205b599f7d0b595801cc764fa86e3ec3acc  bin/musaasm
31ca5fab05bae134c4dbae63556747aba61dceacdad401669e426e72c61b209f  bin/lld
b2bcd65a48baefcec651c4c349a680a51a0f44ed108e1667ca5e4098b31c5010  bin/llvm-dis
7dc5a0b336dc2146336bb57ccdc6ecbe8f63f34cdb0d44dc410a917d529b508c  bin/llvm-readelf
b4251c22a02596c73c49d2146d1ebce49086470953c978351513c5a729cc2ba1  bin/clang-offload-bundler
673a12e3b03ffb8ef8e2a1be3e588d36e434cc7d6b2977ffb293d76696d5a46a  lib/libmusart.so.5.2.0
ac7f11f5f6a9ac3f7c38dfc704fc6a471f8af8cde38c8e13ad07b395b7b30680  lib/libmusart_static.a
f0af9ce9628b9aede9f61c1ee82c89967b8ef685b89ba120b10db27074a0d2c6  lib/libmtrtc.so.5.2.0
0cc4e68e89ee44bf1ac28f3e0d89be1870aba9f648414de62804e829c7ec4289  lib/libmusaasm.so.1.0
e22ae18cbb72b442096bbac4341486a860df368b480a7461b2907dc2c28242ff  mtgpu/bitcode/libdevice.bc
02ac83ee89177aac80e93281e18ef30a3b344c578e567584739e3ebb2a169bde  mtgpu/bitcode/libdevice.mthg.bc
9e51f7724e93bce7d7f3c0b43752d53ee7b37b0a7ec3aa01399358e279cdb766  mtgpu/bitcode/libdevice.31.bc
4178322ac7b45cd1f1e20ee055aed17c529cab17fcb3fe886dad8fc6b554401d  lib/clang/14.0.0/lib/linux/trap_handler.o
```

The remaining authoritative hashes also matched exactly:

```text
d0cdc9b6a46aef579cedbee6edbbe1c8ee92062a66cd7360e98acf20345ca9cb  include/musa.h
090628b68a4e5a4cb614e26e1d1282a526dbf40622e80e8d59e27df205745560  include/musa_runtime_api.h
532388ce480252b58e07954b98558dd924b660bedba58650b9b18d38b52f6d95  include/llvm/Config/llvm-config.h
53bcdb867b2fd52306287f6a7b35a0fc70f875724dfbd81bf1850342e2c1f105  include/llvm/Config/Targets.def
c5a946d3a0c39ad2ed08988621e9eade6b81f84bcb68ed0002e2ea84acfb69cd  include/llvm/ADT/Triple.h
a67736d4c5e15bb832184b01239192e648f9fc83c8cbdd6c445bbb34ae3112c0  include/llvm/IR/CallingConv.h
6af6d92e208c8fbd304aec0be6ebe320e5b5afd83edc03bc86c6122bf2862d3c  include/llvm/MTGPU/MTGPUELF.h
1ba9c8a5f9bc2fa4b0e966be535b4fc8de47b4bfd3b30717bdfc2bc8f8091339  include/llvm/BinaryFormat/ELF.h
f370709ff908dc524fd6f5e68f8586d42871c7259b8c2b0327c9696eb1345b86  include/clang/Basic/SyncScope.h
250d4b8f6dbea9feecfd27decc14adb317cf70a5ca571bef335940cf06c7456a  include/clang/Basic/Version.inc
877e4ca7f0515f2a2699703303a9d5828d809e511b8930caa1b6dc6edfed6178  include/clang/Basic/BuiltinsMTGPU.def
a0d11bbc402668b5f37425ae82d6287794bea29116edfb8dcbebcd467427fd34  include/mtrtc.h
543d316de542a07dabe6b3f8f5dffbde2fdbebfce734b6468c2baab4f571c6a7  include/fatbinary_section.h
20252b0238947aeddb5cb62c5cd37aab9d6e85baaa69d1e830ea4cf3ea1740d6  deps/llvm.version
a2e069bf3144a395cc62466a6a705f55c0718039e06a74a0ae3905c472068368  deps/llvm.mk
```

Direct content replay confirmed toolkit commit
`8c44cbed02a79be2066f1f62bdca039177f71d51`, MCC commit
`8a8cb2971e3084fc442baeacb7447e3d73263dc8`, and runtime commit
`c92b4e82ce65993b9b996b20eb33b1ffd3185dbd`; MCC/Clang 5.2.0/14.0.0; runtime
API 50200; vendor LLVM 14 with MTGPU; Julia LLVM 21.1.8 without MTGPU; calling
convention 102; the four MUSA synchronization-scope names; EM_MTGPU 253; the
MP ELF flag IDs; fatbin constants; and the restrictive installed notice.

The installed root remained a directory with 5,799 regular files, 96
symlinks, and `13,203,250,760` bytes. A bounded name inventory over all of its
regular files returned only LLVM's `LICENSE.TXT`, two LLVM checksum-header
names, and two LLVM WindowsManifest names. It returned no toolkit archive,
vendor checksum file, detached signature, authoritative distribution
manifest, vendor license agreement, `Project.toml`, `Manifest.toml`, or
`Artifacts.toml`. A corresponding tracked-path search at the exact Julia
commit returned no MUSA distribution authority. Static driver/device matrix
search also exited 1. These negative results establish the failures without
using a driver, device, network, package name, or partial file as fallback.

## Executable gate and hostile tests

The S2 Python gate was extracted from the committed receipt and executed
against that same receipt. The canonical validation passed. Its seven hostile
mutations were then applied independently, and all were rejected:

```text
PASS canonical full-denominator gate
PASS rejected stale CUDA name
PASS rejected wrong device digest
PASS rejected missing field
PASS rejected denominator drift
PASS rejected partial replay
PASS rejected fallback
PASS rejected unsupported readiness
```

Thus the executable data is bound to the exact row count/order, counts,
38/38 replay claim, device-library hashes, T02 first blocker, fallback
rejection, and fail-closed readiness rule. CUDA-named internal compiler flags
observed later are vendor implementation details and are not accepted as a
MUSA compatibility mapping.

## Fresh bounded compile, bundle, unbundle, and ELF replay

The operator artifact root named in S2 was not present during independent
review. Consequently, this receipt does not claim to have rehashed the
operator's temporary outputs. A fresh root
`/tmp/gluon-27051446-s2-independent-cpu2` was created and retained. This
transparent independent replay produced:

* stdin source-to-LLVM compilation exited 0 and emitted triple
  `mtgpu-mt-musa`, the exact reported data layout, `mtgpu_kernel`,
  `target-cpu=mp_31`, and MUSA annotations;
* all three hashed bitcode libraries disassembled with the same layout;
  triples were `mtgpu-mt-musa`, `mthg-mt-musa`, and `mtgpu-mt-musa`, with
  features `mp_10`, `mp_42`, and `mp_31`, respectively;
* the `-###` driver trace exited 0 and selected generic `libdevice.bc`, then
  the vendor `lld`, the hashed `trap_handler.o`, and the bundler;
* the actual device-only compile exited 0 and created `gate.o`, SHA-256
  `1043f547141f05f7916166864baddcfc8ab4b0f461e371249dbcfb01be8d1260`;
  system `file` called it `data`, and host `readelf` correctly exited 1 with
  wrong ELF magic. This first failed inspection was not hidden;
* device-object mode exited 0 and created the x86-64 ELF carrier
  `gate-device.o`, SHA-256
  `d86f0b453778b1d2473714e8265adc1ea59308d1f840f5bf39ec54dc2acbc84e`;
* the first independent bundler invocation used unsupported singular option
  spellings and exited 1. After consulting `--help`, the documented plural
  `-inputs/-outputs` replay listed exactly
  `musa-mtgpu-mt-musa-mp_31` and `host-x86_64-unknown-linux-gnu` and exited 0;
* corrected unbundle exited 0 and produced `gate-mtgpu.out`, SHA-256
  `a0620fd6d75c103b75339a70535a94588b6d7f32988886fef5ce1baa2067ddc1`;
  hashed vendor `llvm-readelf` exited 0 and identified ELF64 DYN,
  `EM_MTGPU`, owner MTGPU, note type `0x40`.

Fresh generated-object hashes need not equal hashes from the absent operator
root and are not distribution authorities. This replay authenticates only the
bounded installed frontend/linker/bundler/inspection path. It cannot supply a
Julia caller, an ABI contract, the missing archive authority, or readiness.

## Frozen authoritative offline artifact contract

T02 can move from F only when an approved offline channel supplies one atomic,
owner-identified evidence set containing all of the following:

1. the complete original vendor MUSA Toolkit 5.2.0 distribution archive for
   the explicitly identified supported host/architecture, preserved
   byte-for-byte and named by its vendor distribution identifier;
2. a vendor-published cryptographic checksum covering that exact archive;
3. the vendor's detached signature covering the archive or checksum, plus the
   pinned offline verification key/certificate chain and a successful offline
   verification record;
4. an authoritative manifest for the complete distribution, bound to the
   same vendor release and archive, enumerating every payload path, entry
   type, mode, symlink target where applicable, byte size, and cryptographic
   digest; and
5. provenance identifying the vendor issuer, MUSA 5.2.0 release/build, host
   support tuple, acquisition channel, and immutable hashes of every supplied
   authority file.

An installed directory, package or archive filename, `version.json`,
`install.sh`, component hashes, compiler output, a partial file list, a
WindowsManifest/LLVM manifest name, or a checksum generated only by the
operator does not satisfy this contract. The archive alone is insufficient;
the checksum/signature and complete manifest alone are also insufficient.
License/redistribution rows, driver/device rows, package rows, and ABI rows
remain separate failures even after T02 is supplied.

## Review verification limits

The required `env OMP_NUM_THREADS=2 MAKEFLAGS=-j2 make fix-whitespace` was
attempted after writing this receipt. It exited 2 because its inner shell could
not execute `julia` (exit 127). There is no executable
`/workspace/usr/bin/julia` or `/root/.juliaup/bin/julia`, and `command -v
julia` found none. No installation or fallback was attempted. `git diff
--check`, the independent 40-row parser, the committed canonical validator,
and all seven hostile tests pass, but the static whitespace result is not
reported as a substitute success for the unavailable required target.

## Full-denominator successor contract

The only authorized successor is another metadata gate or `SX/NO_GO`. It must
start from this committed independent-review result as a clean direct child,
declare its exact input authorities, retain CPU2/OMP2 unless separately
authorized, and replay the exact ordered 40-row denominator. All 38 applicable
rows must be reverified from their authorities; no prior P may be carried
forward, no F may be omitted, and no package name, partial artifact, CUDA
analogy, fallback, skipped row, or inconclusive row may be promoted.

The successor must report exact `P/F/S/I/N` counts, preserve O02 and O03 as N
unless scope is explicitly changed, stop at the first ordered failure while
still recording every row, rerun the canonical validator and all seven hostile
mutations, and bind all supplied files and produced evidence by digest and
exact command exit. `GO` is possible only if every applicable row is P. Even
then, metadata-gate completion would authorize no implementation, compile,
link, runtime, support, compatibility, correctness, performance, push, or
deployment claim. Technical evidence remains distinct from formal acceptance.
