# MUSA 5.2.0 S1 metadata and ownership inventory

## Decision

**NO_GO for S2 and every later slice.** This is a metadata inventory only. It
does not claim that Julia, LLVM.jl, GPUCompiler.jl, or MUSA is supported, and
it does not authorize a build, compiler, package manager, vendor executable,
Julia execution, driver query, or GPU use.

The inventory starts at the exact accepted S0 review commit
`a380e087cf97e6b658c6d30129290c08fc42b787` (tree
`40862cb9478dfe2b0f0d123db478985adf25ff6a`, detached and clean). Only tracked
Julia files and static text, metadata, and hashes of the already installed
`/usr/local/musa` tree were read. No credentials, remotes, or external network
were inspected or contacted.

This repair uses rejected subject
`85362498f0edc88fe785bbc0a32b0db44dfa4903` and accepted independent review
`af639e1c8e630cb15de012891f7ff3f5df04c04f` as read-only evidence. Neither is
an ancestor of the repaired result: the result must be a clean direct child of
the accepted S0 commit and must add only this report.

Evidence states are deliberately closed:

* `VERIFIED` means the cited immutable file or tracked file directly supports
  the value.
* `ABSENT` means the required evidence was not present in the allowed inputs.
* `AMBIGUOUS` means local evidence exists but does not establish the required
  exact value or compatibility claim.
* `NOT_APPLICABLE` means the field is outside S1 by definition. It is not a
  pass.

For the denominator, `P/F/S/I/N` means `VERIFIED`, failed closed because
`ABSENT` or `AMBIGUOUS`, skipped, inconclusive, and `NOT_APPLICABLE`,
respectively. A skipped or inconclusive required field would prevent GO.

## Provenance and immutable identities

The installed directory is a real directory (not a symlink), contains 5,799
regular files and 96 symlinks, and occupies 13,203,250,760 bytes at inspection.
Those observations are not a distribution manifest; the original archive and
its vendor signature are absent.

| Item | Evidence and SHA-256 | State |
|---|---|---|
| Toolkit metadata | `/usr/local/musa/version.json`, `0cb715b308fb3d4abcd89f79a0980714db2b048c562cf9bf688a664340382901`; `musa_toolkits` version `5.2.0`, branch `release_musa_5.2.0`, tag `20260602_master`, commit `8c44cbed02a79be2066f1f62bdca039177f71d51` | VERIFIED |
| Installation recipe | `/usr/local/musa/install.sh`, `02917d706f27a1c0d83f8223ab1d03789462d703bf11580d5d57204d27a64d13`; declares `version=5.2.0`, prefix `/usr/local`, and preferred Ubuntu `22.04`/kernel `5.15.0-105-generic` | VERIFIED (identity); AMBIGUOUS (support matrix) |
| MUSA compiler | `bin/mcc -> clang -> clang-14`; resolved payload SHA-256 `324ecf556193490f881c9c5389776129d5aafd80d1856210137593886866ab06`; `Version.inc` SHA-256 `250d4b8f6dbea9feecfd27decc14adb317cf70a5ca571bef335940cf06c7456a`, MCC `5.2.0`, Clang/LLVM `14.0.0` | VERIFIED |
| Assembler/linker payloads | `bin/mtxas` `042c88d4b851584d684aebacca5fed151a9fd37df35b588cc1f4a37b22dbce83`; `bin/musaasm` `e9f15c65f47a74064af902dd9a02c205b599f7d0b595801cc764fa86e3ec3acc`; `bin/lld` `31ca5fab05bae134c4dbae63556747aba61dceacdad401669e426e72c61b209f` | VERIFIED (files only; invocation not performed) |
| Runtime | `lib/libmusart.so.5.2.0` `673a12e3b03ffb8ef8e2a1be3e588d36e434cc7d6b2977ffb293d76696d5a46a`; static archive `ac7f11f5f6a9ac3f7c38dfc704fc6a471f8af8cde38c8e13ad07b395b7b30680`; `musa_runtime` version `5.2.0`, commit `c92b4e82ce65993b9b996b20eb33b1ffd3185dbd` in `version.json`; header `MUSART_VERSION 50200` | VERIFIED |
| Runtime compiler/linker library | `lib/libmtrtc.so.5.2.0` `f0af9ce9628b9aede9f61c1ee82c89967b8ef685b89ba120b10db27074a0d2c6`; `lib/libmusaasm.so.1.0` `0cc4e68e89ee44bf1ac28f3e0d89be1870aba9f648414de62804e829c7ec4289` | VERIFIED |
| Device libraries | `mtgpu/bitcode/libdevice.bc` `e22ae18cbb72b442096bbac4341486a860df368b480a7461b2907dc2c28242ff`; `libdevice.mthg.bc` `02ac83ee89177aac80e93281e18ef30a3b344c578e567584739e3ebb2a169bde`; `libdevice.31.bc` `9e51f7724e93bce7d7f3c0b43752d53ee7b37b0a7ec3aa01399358e279cdb766` | VERIFIED (static files in the working-tree replay); T08 remains failed until this frozen identity is replayed at the committed repaired result; AMBIGUOUS (selection/ISA mapping) |
| Original toolkit archive, complete manifest, signature, and source checksum | No archive, signature, or authoritative manifest was in tracked files or approved cache | ABSENT |

The installed files are x86-64 GNU/Linux according to static `file` metadata;
that is not evidence of supported host distributions or a driver/device being
installed. The actual driver, device model/UUID, firmware, and ISA capability
matrix were not queried.

## ABI, ISA, and LLVM expectations

The vendor installation statically documents LLVM `14.0.0`,
`LLVM_TARGETS_TO_BUILD=X86;MTGPU`,
`LLVM_DEFINITIONS=-DENABLE_MTGPU_TARGET -D__MTGPU__`, `mtgpu` and
`mthg` architecture enums, and a MUSA OS enum. It defines MUSA kernel calling
conventions `MTGPU_KERNEL = 102` and `MTGPU_RT_Indirect = 103`, synchronization
scopes `musa_singlethread`, `musa_block`, `musa_device`, and `musa_system`, and
fatbin envelope constants `FATBINC_MAGIC 0x466243B1`, version `1`, link version
`2`, and section `.mt_fatbin`. Header API constants are `MUSA_VERSION 50200`
and `MUSART_VERSION 50200`. These are vendor-header expectations, not proof
that Julia's LLVM can consume them.

The demo CMake file names `--offload-arch=mp_10`, `mp_21`, `mp_22`, and `mp_31`;
`version.json` records math libraries built for `22,31` (or `22;31`). No local
document maps these IDs to a device model, specifies an exact device target
triple/data layout, address-space numbers and semantics, kernel parameter ABI,
relocations/code-object format, device-library selection/link order, or the
driver/runtime compatibility matrix. The presence of LLVM bitcode and a fatbin
wrapper does not establish whether a prospective Julia package should emit
LLVM IR, bitcode, vendor assembly, or a linked fatbin. All those fields are
`AMBIGUOUS` or `ABSENT` below and are hard blockers.

Julia itself is pinned by tracked `deps/llvm.version` to LLVM `21.1.8` /
`julia-21.1.8-0` (`libLLVM` JLL `21.1.8+0`); its tracked default target list is
`host;NVPTX;AMDGPU;WebAssembly;BPF;AVR`, with no MTGPU target. No adapter,
patched-Julia LLVM build, or compatibility statement is present. CUDA
resemblance is not evidence and is not assumed.

## Julia package and ownership closure

No tracked or local-cached `Project.toml`, `Manifest.toml`, repository, or
artifact identifies a maintained Julia MUSA package. Consequently the exact
repository URL, immutable commit, maintainer/owner, Julia bounds,
GPUCompiler.jl bounds, LLVM.jl bounds, artifacts, registry provenance, and
test matrix are all `ABSENT`. The minimum owner request is:

> Provide the maintained package repository URL and a full 40-hex commit, its
> complete Project/Manifest and registry/artifact hashes, and explicit tested
> bounds for Julia, GPUCompiler.jl, and LLVM.jl. An operator may verify a
> supplied checkout without contacting a remote using
> `git -C /approved/MUSA-package rev-parse HEAD` and
> `sha256sum /approved/MUSA-package/Project.toml /approved/MUSA-package/Manifest.toml`.

Ownership remains separated:

| Boundary | Owner | S1 conclusion |
|---|---|---|
| Host Julia bootstrap, GC, tasks, CPU JIT, images, generic compiler seams | Julia core | No defect or change demonstrated; do not edit core |
| Target-independent inference/codegen orchestration | GPUCompiler/shared GPU layer | No MUSA package or compatibility evidence supplied |
| MUSA target, intrinsics, ABI, runtime/driver bindings, device libraries, launch | External MUSA Julia package plus vendor toolkit | External owner is presumptive; exact package identity is absent |
| Vendor LLVM MTGPU backend and proprietary artifacts | MUSA owner | Vendor payload is present; redistribution permission is absent |

## License and redistributability

`install.sh` (hash above) states that the software is proprietary and
confidential and that copying or disclosure to third parties is prohibited
without Moore Threads' express written consent. This is verified evidence of a
restrictive notice, not permission to redistribute. The actual License
Agreement, per-component terms, and written consent for Julia artifacts are not
present. The bundled LLVM notice is independently Apache-2.0 WITH LLVM-exception
(`include/llvm/Support/LICENSE.TXT`, SHA-256
`54cbc326a78b9400065bfc5830a57fdcdaf808286d4ac35d8a9e324aa77b7241`), but it
does not license the MUSA additions or vendor libraries. Redistribution is
therefore `ABSENT` and a hard `NO_GO`.

Minimal owner acquisition request (not executed): supply the exact vendor
archive plus signature/checksum and the license agreement/consent in an
approved offline inbox, then record `sha256sum` for the archive and each
redistributed component. Do not download or infer permission from this
installed directory.

## S1 field denominator

| ID | Required field | State | Outcome |
|---|---|---|---|
| T01 | toolkit 5.2.0 identity/commits | VERIFIED | P |
| T02 | original archive/signature/hash | ABSENT | F |
| T03 | supported host OS/architectures | AMBIGUOUS | F |
| T04 | complete immutable offline layout | AMBIGUOUS | F |
| T05 | compiler identity/hash | VERIFIED | P |
| T06 | assembler/linker identities/hashes | VERIFIED | P |
| T07 | runtime identity/hash/API version | VERIFIED | P |
| T08 | device-library hashes | corrected identity awaits replay at committed repaired result | F |
| T09 | driver ABI/version matrix | ABSENT | F |
| T10 | device/firmware inventory and ISA matrix | ABSENT | F |
| A01 | vendor LLVM version/backend | VERIFIED | P |
| A02 | Julia LLVM version/target list | VERIFIED | P |
| A03 | vendor-to-Julia LLVM compatibility bridge | ABSENT | F |
| A04 | accepted input IR/object formats | AMBIGUOUS | F |
| A05 | exact device target triple | ABSENT | F |
| A06 | data layout | ABSENT | F |
| A07 | ISA ID to device mapping | AMBIGUOUS | F |
| A08 | exact code-object/fatbin ABI | AMBIGUOUS | F |
| A09 | kernel calling convention | VERIFIED | P |
| A10 | address-space numbers/semantics | ABSENT | F |
| A11 | intrinsic and device-library ABI | AMBIGUOUS | F |
| A12 | device-library selection/link order | ABSENT | F |
| A13 | atomics/synchronization semantics | AMBIGUOUS | F |
| A14 | exception/error/debug ABI | ABSENT | F |
| A15 | runtime/driver ABI compatibility | ABSENT | F |
| P01 | maintained Julia MUSA repository | ABSENT | F |
| P02 | exact package commit | ABSENT | F |
| P03 | package owner/maintenance evidence | ABSENT | F |
| P04 | Julia compatibility bounds | ABSENT | F |
| P05 | GPUCompiler compatibility bounds | ABSENT | F |
| P06 | LLVM.jl compatibility bounds | ABSENT | F |
| P07 | package Project/Manifest/registry/artifact hashes | ABSENT | F |
| P08 | package test matrix and provenance | ABSENT | F |
| L01 | exact vendor license agreement | ABSENT | F |
| L02 | redistribution permission/consent | ABSENT | F |
| L03 | per-component license mapping | AMBIGUOUS | F |
| L04 | third-party notices beyond LLVM | ABSENT | F |
| O01 | separated Julia/GPUCompiler/external ownership | VERIFIED | P |
| O02 | Julia-core source change in S1 | NOT_APPLICABLE | N |
| O03 | compile, runtime, or GPU result | NOT_APPLICABLE | N |

Denominator: **40 fields — P=8, F=30, S=0, I=0, N=2**. The 30 failures are
not silently promoted to `INCONCLUSIVE`: the required evidence is demonstrably
missing or insufficient in the allowed inputs.

## Exact S2 entry predicate

S2 may be entered only in a fresh worktree at the committed S1 result whose
sole parent is `a380e087cf97e6b658c6d30129290c08fc42b787` and whose sole changed
path is this document. All of the following must then be true, with no network,
package manager, Julia, compiler, linker, vendor executable, or GPU invocation
during the preflight:

1. All 38 applicable fields are `VERIFIED` at the committed repaired S1
   result, with immutable hashes and an owner-approved provenance record. This
   requires replay of every current pass (T01, T05–T07, A01–A02, A09, and O01),
   replay and verification of corrected T08, and closure of T02–T04, T09–T10,
   A03–A08, A10–A15, P01–P08, and L01–L04. O02 and O03 remain
   `NOT_APPLICABLE`; no applicable field may be skipped or inconclusive.
2. The supplied Julia MUSA package has a full 40-hex repository commit and
   locked Project/Manifest, registry, source, and artifact hashes; its tested
   Julia/GPUCompiler.jl/LLVM.jl bounds include the frozen environment.
3. The vendor archive/signature/license expressly permit the exact proposed
   offline use and redistribution, and every compiler, runtime, linker,
   device-library, and driver input is present and hashed.
4. A static resolution table maps every input to an approved cache object or
   approved system file; the replay is bound to the committed repaired result,
   `git diff --check` is clean, and all 38 applicable fields—not merely the
   fields currently failed—have been reverified.

Until that predicate is satisfied, the only valid successor is `SX` with the
owner acquisition requests above. S1 establishes metadata and ownership
closure only; it establishes no Julia or MUSA support claim.

## Read-only evidence commands

The probes used were limited to `git`, `rg`, `sed`, `stat`, `readlink`, `find`,
`du`, `sha256sum`, and system `file` metadata. No output from a vendor binary,
compiler, linker, Julia, package manager, driver, or GPU was obtained. The
tracked core/package-source search found no MUSA implementation, and the allowed
local project search found no Julia MUSA package. Outside the toolkit and the
two tracked research documents, the only name hit was the unrelated static
smoke script `/opt/gluon/bin/codex-musa-smoke`.

The corrected `libdevice.31.bc` value above is exactly 64 hexadecimal
characters and matched the authorized installed file during the working-tree
replay. T08 nevertheless remains failed in this inventory until an independent
static replay is performed against the committed repaired result. This is
metadata closure only, not Julia/MUSA implementation or compatibility proof;
technical success is not formal acceptance.
