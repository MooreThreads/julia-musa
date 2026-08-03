# MUSA 5.2.0 S2 metadata compatibility gate evidence

## Decision and frozen scope

**NO_GO.** All 38 applicable fields were independently revalidated at the
exact accepted S1 result `228dab02283d62c0f4c1429d649dbe1bd9ad5b3e`
(tree `35655e55fb92baf6f9e2ce57113ee6f261703d31`). The stable denominator is
40 fields: **P=11, F=27, S=0, I=0, N=2; applicable=38**. The corrected S1
baseline was P=8, F=30, S=0, I=0, N=2. Only T08, A05, and A06 moved to P,
on new evidence recorded below. No other S1 failure was weakened or carried
forward without replay.

T02 is the exact first blocker: the installed tree has no original toolkit
archive, vendor signature, or authoritative complete distribution manifest.
Later independent observations are retained because the task required a full
38-field replay, but none bypass T02. In particular, the compiler's use of
CUDA-named internal flags and wrappers is an observed vendor implementation
detail, not authority for a CUDA-to-MUSA mapping.

The work used no network, package manager, credentials, service, database,
driver or device query, GPU, Julia execution, cleanup, formal review, push, or
deployment. CPU-only commands used `OMP_NUM_THREADS=2` and `MAKEFLAGS=-j2`.
Compile artifacts remain under the unique root
`/tmp/gluon-caa2b3c4-s2-cpu2`. Technical evidence is not formal acceptance.

## Immutable authorities and callers

The installed identity root is `/usr/local/musa/version.json`, SHA-256
`0cb715b308fb3d4abcd89f79a0980714db2b048c562cf9bf688a664340382901`:
toolkit 5.2.0, toolkit commit
`8c44cbed02a79be2066f1f62bdca039177f71d51`, MCC commit
`8a8cb2971e3084fc442baeacb7447e3d73263dc8`, and runtime commit
`c92b4e82ce65993b9b996b20eb33b1ffd3185dbd`. The recipe
`/usr/local/musa/install.sh` is
`02917d706f27a1c0d83f8223ab1d03789462d703bf11580d5d57204d27a64d13`.

The installed payload identities used by the gate are:

| Authority | SHA-256 |
|---|---|
| `bin/clang-14` (`mcc` and `clang` resolve here) | `324ecf556193490f881c9c5389776129d5aafd80d1856210137593886866ab06` |
| `bin/mtxas` | `042c88d4b851584d684aebacca5fed151a9fd37df35b588cc1f4a37b22dbce83` |
| `bin/musaasm` | `e9f15c65f47a74064af902dd9a02c205b599f7d0b595801cc764fa86e3ec3acc` |
| `bin/lld` | `31ca5fab05bae134c4dbae63556747aba61dceacdad401669e426e72c61b209f` |
| `bin/llvm-dis` | `b2bcd65a48baefcec651c4c349a680a51a0f44ed108e1667ca5e4098b31c5010` |
| `bin/llvm-readelf` | `7dc5a0b336dc2146336bb57ccdc6ecbe8f63f34cdb0d44dc410a917d529b508c` |
| `bin/clang-offload-bundler` | `b4251c22a02596c73c49d2146d1ebce49086470953c978351513c5a729cc2ba1` |
| `lib/libmusart.so.5.2.0` | `673a12e3b03ffb8ef8e2a1be3e588d36e434cc7d6b2977ffb293d76696d5a46a` |
| `lib/libmusart_static.a` | `ac7f11f5f6a9ac3f7c38dfc704fc6a471f8af8cde38c8e13ad07b395b7b30680` |
| `lib/libmtrtc.so.5.2.0` | `f0af9ce9628b9aede9f61c1ee82c89967b8ef685b89ba120b10db27074a0d2c6` |
| `lib/libmusaasm.so.1.0` | `0cc4e68e89ee44bf1ac28f3e0d89be1870aba9f648414de62804e829c7ec4289` |
| `mtgpu/bitcode/libdevice.bc` | `e22ae18cbb72b442096bbac4341486a860df368b480a7461b2907dc2c28242ff` |
| `mtgpu/bitcode/libdevice.mthg.bc` | `02ac83ee89177aac80e93281e18ef30a3b344c578e567584739e3ebb2a169bde` |
| `mtgpu/bitcode/libdevice.31.bc` | `9e51f7724e93bce7d7f3c0b43752d53ee7b37b0a7ec3aa01399358e279cdb766` |
| `lib/clang/14.0.0/lib/linux/trap_handler.o` | `4178322ac7b45cd1f1e20ee055aed17c529cab17fcb3fe886dad8fc6b554401d` |

Relevant installed header identities are `musa.h`
`d0cdc9b6a46aef579cedbee6edbbe1c8ee92062a66cd7360e98acf20345ca9cb`,
`musa_runtime_api.h`
`090628b68a4e5a4cb614e26e1d1282a526dbf40622e80e8d59e27df205745560`,
`llvm/Config/llvm-config.h`
`532388ce480252b58e07954b98558dd924b660bedba58650b9b18d38b52f6d95`,
`llvm/Config/Targets.def`
`53bcdb867b2fd52306287f6a7b35a0fc70f875724dfbd81bf1850342e2c1f105`,
`llvm/ADT/Triple.h`
`c5a946d3a0c39ad2ed08988621e9eade6b81f84bcb68ed0002e2ea84acfb69cd`,
`llvm/IR/CallingConv.h`
`a67736d4c5e15bb832184b01239192e648f9fc83c8cbdd6c445bbb34ae3112c0`,
`llvm/MTGPU/MTGPUELF.h`
`6af6d92e208c8fbd304aec0be6ebe320e5b5afd83edc03bc86c6122bf2862d3c`,
`llvm/BinaryFormat/ELF.h`
`1ba9c8a5f9bc2fa4b0e966be535b4fc8de47b4bfd3b30717bdfc2bc8f8091339`,
`clang/Basic/SyncScope.h`
`f370709ff908dc524fd6f5e68f8586d42871c7259b8c2b0327c9696eb1345b86`,
`clang/Basic/Version.inc`
`250d4b8f6dbea9feecfd27decc14adb317cf70a5ca571bef335940cf06c7456a`,
`clang/Basic/BuiltinsMTGPU.def`
`877e4ca7f0515f2a2699703303a9d5828d809e511b8930caa1b6dc6edfed6178`,
`mtrtc.h`
`a0d11bbc402668b5f37425ae82d6287794bea29116edfb8dcbebcd467427fd34`,
and `fatbinary_section.h`
`543d316de542a07dabe6b3f8f5dffbde2fdbebfce734b6468c2baab4f571c6a7`.

The only relevant Julia callers are target-neutral ownership seams. At the
frozen commit, `deps/llvm.version` (SHA-256
`20252b0238947aeddb5cb62c5cd37aab9d6e85baaa69d1e830ea4cf3ea1740d6`)
pins LLVM 21.1.8 / `julia-21.1.8-0`, while `deps/llvm.mk` (SHA-256
`a2e069bf3144a395cc62466a6a705f55c0718039e06a74a0ae3905c472068368`)
builds `host;NVPTX;AMDGPU;WebAssembly;BPF;AVR`. `base/genericmemory.jl`
states that non-CPU address-space semantics belong to the backend, and
`src/aotcompile.cpp` exposes a target-neutral native-emission seam. A tracked
search found no MUSA, MTGPU, package, metadata, or build caller outside the
frozen receipts (C09, exit 1). Therefore no production or build-system edit
is locally justified.

## Full field replay

`P` means the exact required value is verified. `F` means allowed local
evidence proves absence or remains insufficient for the exact compatibility
claim. `N` is one of the two frozen S1 non-applicable fields. Every row names
its installed/tracked source, repository caller (or its proven absence),
observed value, and command with exact exit.

| ID | Required field | Exact source and caller | Observed authoritative value | Disposition | Command/exit |
|---|---|---|---|---|---|
| T01 | toolkit 5.2.0 identity/commits | `version.json`; no Julia caller | 5.2.0 and commits above | P | C02/0 |
| T02 | original archive/signature/hash | installed-tree archive/signature search; no caller | no archive, signature, or distribution manifest | F, first blocker | C03/0, no matching archive/signature/manifest |
| T03 | supported host OS/architectures | `install.sh`; no caller | preferred Ubuntu 22.04/kernel only; x86-64 payload is not a support matrix | F | C04/0 |
| T04 | complete immutable offline layout | installed tree; no caller | 5,799 files, 96 symlinks, 13,203,250,760 bytes, but no authoritative manifest | F | C05/0 |
| T05 | compiler identity/hash | `mcc -> clang -> clang-14`; no caller | MCC 5.2.0, Clang 14.0.0, MCC commit and digest above | P | C06/0 |
| T06 | assembler/linker identities/hashes | `mtxas`, `musaasm`, `lld`; no caller | exact digests above | P | C02/0 |
| T07 | runtime identity/hash/API version | runtime libraries, `version.json`, `musa_runtime_api.h`; no caller | runtime 5.2.0, commit above, `MUSART_VERSION=50200` | P | C02/0, C04/0 |
| T08 | device-library hashes | three installed bitcode files; no caller | exact three digests above, independently replayed at accepted base | P | C02/0, C07/0 |
| T09 | driver ABI/version matrix | `version.json`, `install.sh`; no caller | no driver identity or compatibility matrix | F | C10/1 |
| T10 | device/firmware inventory and ISA matrix | allowed static metadata; no caller | no device, UUID, firmware, or device-to-ISA matrix; no query made | F | C10/1 |
| A01 | vendor LLVM version/backend | `llvm-config.h`, `Targets.def`, compiler; no caller | LLVM 14.0.0 with MTGPU target | P | C04/0, C06/0 |
| A02 | Julia LLVM version/target list | `deps/llvm.version`, `deps/llvm.mk` | LLVM 21.1.8; no MTGPU target | P | C04/0 |
| A03 | vendor-to-Julia LLVM compatibility bridge | both LLVM identities; no MUSA caller | version/backend mismatch and no adapter or compatibility statement | F | C09/1 |
| A04 | accepted input IR/object formats | `mcc`, `mtrtc.h`; no Julia MUSA caller | source-to-LLVM and source-to-carrier paths observed; complete accepted Julia-facing input contract absent | F | C08/0, C13/0 |
| A05 | exact device target triple | compiler IR and all three bitcodes; no Julia caller | `mtgpu-mt-musa`; `mthg-mt-musa` for MTHG bitcode | P | C07/0, C08/0 |
| A06 | data layout | compiler IR and all three bitcodes; no Julia caller | `e-p:64:64:64:64-p1:64:64:64:64-p2:64:64:64:64-p3:32:32-p4:32:32-p5:64:64-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128` | P | C07/0, C08/0 |
| A07 | ISA ID to device mapping | `ELF.h`, compiler target features; no caller | MP IDs/ELF flags exist, but no device-model mapping | F | C04/0 |
| A08 | exact code-object/fatbin ABI | `MTGPUELF.h`, `ELF.h`, `fatbinary_section.h`; no caller | EM_MTGPU ELF and metadata note observed; complete code-object/fatbin contract absent | F | C14/0 |
| A09 | kernel calling convention | `CallingConv.h`, emitted IR; no caller | `MTGPU_KERNEL=102`; emitted `mtgpu_kernel` | P | C04/0, C08/0 |
| A10 | address-space numbers/semantics | data layout, `MTGPUELF.h`, `base/genericmemory.jl` | pointer widths and metadata enums exist; exact LLVM numbers plus semantics absent | F | C04/0 |
| A11 | intrinsic and device-library ABI | installed builtins/bitcode; no caller | symbols and builtins exist; complete callable ABI absent | F | C07/0 |
| A12 | device-library selection/link order | `mcc -###`; no Julia caller | mp_31 probe selects generic `libdevice.bc`, then object and `trap_handler.o`; no authoritative Julia selection policy | F | C11/0 |
| A13 | atomics/synchronization semantics | `SyncScope.h`; no caller | four MUSA scope names exist; ordering and target semantics incomplete | F | C04/0 |
| A14 | exception/error/debug ABI | emitted attributes and headers; no caller | one `nounwind` kernel is not a complete ABI | F | C08/0 |
| A15 | runtime/driver ABI compatibility | runtime identity only; no caller | no driver identity or compatibility matrix | F | C10/1 |
| P01 | maintained Julia MUSA repository | tracked/installed package search | none | F | C09/1, C15/0 empty |
| P02 | exact package commit | no package caller | none | F | C09/1 |
| P03 | package owner/maintenance evidence | no package caller | none | F | C09/1 |
| P04 | Julia compatibility bounds | no `Project.toml`/package | none | F | C15/0 empty |
| P05 | GPUCompiler compatibility bounds | no `Project.toml`/package | none | F | C15/0 empty |
| P06 | LLVM.jl compatibility bounds | no `Project.toml`/package | none | F | C15/0 empty |
| P07 | package Project/Manifest/registry/artifact hashes | installed exact-name search | none | F | C15/0 empty |
| P08 | package test matrix and provenance | no package caller | none | F | C09/1 |
| L01 | exact vendor license agreement | installed license search; no caller | agreement referenced but not present | F | C03/0 |
| L02 | redistribution permission/consent | `install.sh`; no caller | express written consent required; none present | F | C04/0 |
| L03 | per-component license mapping | installed notices; no caller | LLVM notice only; no vendor-wide mapping | F | C03/0 |
| L04 | third-party notices beyond LLVM | installed notices; no caller | none beyond LLVM found | F | C03/0 |
| O01 | separated Julia/GPUCompiler/external ownership | tracked Julia seams and accepted receipts | Julia remains target-neutral; external/vendor ownership remains separated | P | C04/0, C09/1 |
| O02 | Julia-core source change in S2 | repository diff | no production change justified | N | C01/0 |
| O03 | runtime or GPU result | prohibited and not executed | outside metadata gate | N | C01/0 |

## Command and bounded compile evidence

Commands were run from `/workspace`; paths below are unabbreviated in the
actual invocations.

* C01 (exit 0 for each): `git rev-parse HEAD HEAD^{tree}` returned the frozen
  identities; `git status --porcelain=v1 --untracked-files=all` and
  `git diff --check` were empty.
* C02 (exit 0): `sha256sum` over the installed identity, tools, runtime,
  headers, and all three device libraries returned the digests above.
* C03 (exit 0, only LLVM license and name-only WindowsManifest hits):
  `find /usr/local/musa -xdev -type f`
  with archive, signature, manifest, license, copying, notice, Project, and
  Manifest name predicates. There was no archive, signature, distribution
  manifest, or vendor license agreement.
* C04 (exit 0): targeted `rg`/`sed` replay of version, LLVM target, triple,
  calling-convention, ELF, fatbin, synchronization, ownership, and license
  definitions in the hashed installed and tracked sources.
* C05 (exit 0): `find` file/link counts, `du -sb`, `stat`, `readlink -f`, and
  `file` returned the installed layout and payload types recorded above.
* C06 (exit 0): with CPU2/OMP2, `/usr/local/musa/bin/mcc --version` returned
  Clang 14.0.0, MCC 5.2.0, the exact MCC commit, target
  `x86_64-unknown-linux-gnu`, and installed directory `/usr/local/musa/bin`.
* C07 (exit 0): hashed `llvm-dis` over each device library returned the exact
  triples and common data layout. Attributes identify generic
  `libdevice.bc` with `+mp_10`, `libdevice.31.bc` with `mp_31`, and
  `libdevice.mthg.bc` with `mp_42` and the MTHG triple.
* C08 (exit 0): a side-effect-free stdin kernel compiled with
  `mcc -x musa --offload-arch=mp_31 --musa-device-only -S -emit-llvm -o - -`.
  It emitted the exact triple/layout, `mtgpu_kernel`, `target-cpu=mp_31`, and
  MUSA annotations. This authenticates a vendor frontend path only.
* C09 (exit 1, empty): frozen tracked `git grep` for MUSA.jl, MUSA package,
  MTGPU, MThreads, and Moore Threads outside the receipts. No repository
  metadata/build/package caller exists.
* C10 (exit 1, empty): static `rg` for driver compatibility/version and
  device UUID/firmware/ISA identity in `version.json` and `install.sh`.
* C11 (exit 0): the same kernel with `mcc -### ... --musa-device-only -c`
  selected `libdevice.bc`, then `lld` with the generated object and the hashed
  `trap_handler.o`, and then `clang-offload-bundler`. CUDA-named internal
  cc1 flags/wrappers in this output were not adopted as MUSA metadata.
* C12 (overall exit 1): an actual `--musa-device-only -c` compile produced
  retained `gate.o`
  (`6f53c29a81480ec45952cd5baf22b453a5d52a264007ba9b2d753791f7c412cd`),
  which system `file` called `data`;
  `readelf` then correctly rejected it as non-ELF. No code-object claim is
  based on this carrier.
* C13 (exit 0): `mcc --musa-device-obj-only -c` produced retained host ELF
  carrier `gate-device.o`, SHA-256
  `075e0c8f12891fb624f876172c3a4933993481da0fe2910f0c3486f4fd241d1c`.
  The hashed bundler listed exactly `musa-mtgpu-mt-musa-mp_31` and
  `host-x86_64-unknown-linux-gnu`.
* C14 (exit 0): the hashed bundler extracted retained `gate-mtgpu.out`,
  SHA-256 `bd2029227ca57739af26452bc73466a785ca92e0165d1b4d536b8a701bec7cb0`;
  the hashed vendor `llvm-readelf` identified ELF64 DYN, `EM_MTGPU`, and MTGPU
  note type 64. The host `readelf`'s stale name for machine 253 was rejected.
* C15 (exit 0, empty): exact-name `find` for `Project.toml`, `Manifest.toml`,
  and `Artifacts.toml` under `/usr/local/musa`.
* C16 (exit 2; inner shell exit 127): the required
  `env OMP_NUM_THREADS=2 MAKEFLAGS=-j2 make fix-whitespace` could not start
  `contrib/check-whitespace.jl` because `julia` is absent. There is no
  `/workspace/usr/bin/julia`, no executable `/root/.juliaup/bin/julia`, and no
  executable named `julia` under the inspected `/opt`, `/usr/local`, or
  `/workspace` roots. No install or fallback was attempted. `git diff --check`
  remains the bounded static whitespace evidence, not a substitute success for
  the unavailable target.

The first failed inspection in C12 was retained and followed by the explicit
device-object mode rather than hidden or retried away. C13/C14 authenticate
only the locally installed compiler/bundler/inspection path; they do not
authenticate a missing Julia caller or prove runtime readiness.

## Executable denominator and hostile-mutation tests

The following canonical data is redundant with the human table so a focused
test can fail closed on denominator drift, partial replay, fallback, stale
CUDA substitution, device-library digest changes, missing rows, and unsupported
readiness claims.

<!-- S2_GATE_DATA_BEGIN -->
```text
DENOMINATOR=40
APPLICABLE=38
COUNTS=P11,F27,S0,I0,N2
REVALIDATED=38/38
READINESS=NO_GO
FIRST_BLOCKER=T02
FALLBACK=REJECT
DEVICE_DIGESTS=libdevice.bc:e22ae18cbb72b442096bbac4341486a860df368b480a7461b2907dc2c28242ff,libdevice.mthg.bc:02ac83ee89177aac80e93281e18ef30a3b344c578e567584739e3ebb2a169bde,libdevice.31.bc:9e51f7724e93bce7d7f3c0b43752d53ee7b37b0a7ec3aa01399358e279cdb766
T01|P|version.json|none|5.2.0 toolkit commit|C02/0|yes
T02|F|installed archive search|none|archive signature manifest absent|C03/0-empty|yes
T03|F|install.sh|none|preference is not support matrix|C04/0|yes
T04|F|installed tree|none|no authoritative manifest|C05/0|yes
T05|P|clang-14|none|MCC 5.2.0 Clang 14.0.0|C06/0|yes
T06|P|mtxas musaasm lld|none|hashed payloads|C02/0|yes
T07|P|runtime headers libraries|none|runtime 5.2.0 API 50200|C02/0|yes
T08|P|three installed bitcodes|none|three exact SHA-256 identities|C02/0+C07/0|yes
T09|F|static metadata|none|driver matrix absent|C10/1|yes
T10|F|static metadata|none|device firmware ISA matrix absent|C10/1|yes
A01|P|vendor LLVM headers|none|LLVM 14.0.0 MTGPU|C04/0+C06/0|yes
A02|P|deps/llvm.version deps/llvm.mk|Julia build|LLVM 21.1.8 no MTGPU|C04/0|yes
A03|F|vendor and Julia LLVM identities|none|bridge absent|C09/1|yes
A04|F|mcc mtrtc.h|none|complete Julia-facing input contract absent|C08/0+C13/0|yes
A05|P|compiler IR and bitcodes|none|mtgpu-mt-musa and mthg-mt-musa|C07/0+C08/0|yes
A06|P|compiler IR and bitcodes|none|exact pointer and vector data layout|C07/0+C08/0|yes
A07|F|ELF.h|none|device-model mapping absent|C04/0|yes
A08|F|MTGPUELF.h ELF.h fatbinary_section.h|none|complete ABI absent|C14/0|yes
A09|P|CallingConv.h emitted IR|none|MTGPU_KERNEL 102|C04/0+C08/0|yes
A10|F|data layout MTGPUELF.h|genericmemory.jl|numbers plus semantics absent|C04/0|yes
A11|F|builtins and bitcode|none|complete callable ABI absent|C07/0|yes
A12|F|mcc driver trace|none|Julia selection and link policy absent|C11/0|yes
A13|F|SyncScope.h|none|ordering semantics incomplete|C04/0|yes
A14|F|emitted attributes headers|none|complete exception error debug ABI absent|C08/0|yes
A15|F|runtime identity|none|driver compatibility absent|C10/1|yes
P01|F|tracked and installed search|none|package absent|C09/1+C15/0-empty|yes
P02|F|package search|none|commit absent|C09/1|yes
P03|F|package search|none|owner evidence absent|C09/1|yes
P04|F|package search|none|Julia bounds absent|C15/0-empty|yes
P05|F|package search|none|GPUCompiler bounds absent|C15/0-empty|yes
P06|F|package search|none|LLVM.jl bounds absent|C15/0-empty|yes
P07|F|package search|none|lock and hashes absent|C15/0-empty|yes
P08|F|package search|none|test provenance absent|C09/1|yes
L01|F|license search|none|agreement absent|C03/0-empty|yes
L02|F|install.sh|none|consent absent|C04/0|yes
L03|F|notice search|none|component mapping absent|C03/0|yes
L04|F|notice search|none|notices beyond LLVM absent|C03/0|yes
O01|P|tracked ownership seams|target-neutral seams|ownership separated|C04/0+C09/1|yes
O02|N|repository diff|none|no core change|C01/0|yes
O03|N|frozen scope|none|no runtime or GPU result|C01/0|yes
```
<!-- S2_GATE_DATA_END -->

The test below is embedded in this sole receipt. It reads the canonical block,
requires the exact ordered field set and counts, rejects CUDA/NVPTX names in
gate data, binds the three device-library digests, requires all applicable
rows to say `yes`, and permits `GO` only if every applicable row is P. Its
`--self-test` mode applies seven hostile mutations and requires each to fail.

<!-- S2_GATE_TEST_BEGIN -->
```python
import collections
import pathlib
import sys

IDS = [f"T{i:02d}" for i in range(1, 11)]
IDS += [f"A{i:02d}" for i in range(1, 16)]
IDS += [f"P{i:02d}" for i in range(1, 9)]
IDS += [f"L{i:02d}" for i in range(1, 5)]
IDS += [f"O{i:02d}" for i in range(1, 4)]
DIGESTS = (
    "libdevice.bc:e22ae18cbb72b442096bbac4341486a860df368b480a7461b2907dc2c28242ff,"
    "libdevice.mthg.bc:02ac83ee89177aac80e93281e18ef30a3b344c578e567584739e3ebb2a169bde,"
    "libdevice.31.bc:9e51f7724e93bce7d7f3c0b43752d53ee7b37b0a7ec3aa01399358e279cdb766"
)

def validate(text):
    start = text.index("<!-- S2_GATE_DATA_BEGIN -->")
    end = text.index("<!-- S2_GATE_DATA_END -->", start)
    block = text[start:end]
    lines = [line for line in block.splitlines()
             if line and not line.startswith(("<!--", "```"))]
    meta_lines = [line for line in lines if "|" not in line]
    meta_pairs = [line.split("=", 1) for line in meta_lines]
    assert len(meta_pairs) == 8 and len({pair[0] for pair in meta_pairs}) == 8
    meta = dict(meta_pairs)
    rows = [line.split("|") for line in lines if "|" in line]
    assert meta == {
        "DENOMINATOR": "40", "APPLICABLE": "38",
        "COUNTS": "P11,F27,S0,I0,N2", "REVALIDATED": "38/38",
        "READINESS": "NO_GO", "FIRST_BLOCKER": "T02",
        "FALLBACK": "REJECT", "DEVICE_DIGESTS": DIGESTS,
    }
    assert len(rows) == 40 and [row[0] for row in rows] == IDS
    assert all(len(row) == 7 and all(row) for row in rows)
    counts = collections.Counter(row[1] for row in rows)
    assert counts == {"P": 11, "F": 27, "N": 2}
    applicable = [row for row in rows if row[1] != "N"]
    assert len(applicable) == 38 and all(row[6] == "yes" for row in applicable)
    assert rows[1][0:2] == ["T02", "F"]
    assert not any(name in block.lower() for name in ("cuda", "nvptx"))
    if meta["READINESS"] == "GO":
        assert all(row[1] == "P" for row in applicable)

def main():
    path = pathlib.Path(sys.argv[1])
    original = path.read_text(encoding="utf-8")
    validate(original)
    print("PASS canonical full-denominator gate")
    if "--self-test" not in sys.argv[2:]:
        return
    mutations = {
        "stale CUDA name": lambda s: s.replace(
            "A05|P|compiler IR and bitcodes|none|mtgpu-mt-musa and mthg-mt-musa",
            "A05|P|compiler IR and bitcodes|none|nvptx64-nvidia-cuda and mthg-mt-musa", 1),
        "wrong device digest": lambda s: s.replace(
            "DEVICE_DIGESTS=libdevice.bc:e22ae18c",
            "DEVICE_DIGESTS=libdevice.bc:00000000", 1),
        "missing field": lambda s: s.replace(next(line for line in s.splitlines()
                                                    if line.startswith("A15|")) + "\n", "", 1),
        "denominator drift": lambda s: s.replace("DENOMINATOR=40", "DENOMINATOR=39", 1),
        "partial replay": lambda s: s.replace("REVALIDATED=38/38", "REVALIDATED=37/38", 1),
        "fallback": lambda s: s.replace("FALLBACK=REJECT", "FALLBACK=ALLOW", 1),
        "unsupported readiness": lambda s: s.replace("READINESS=NO_GO", "READINESS=GO", 1),
    }
    for name, mutate in mutations.items():
        try:
            validate(mutate(original))
        except (AssertionError, ValueError):
            print(f"PASS rejected {name}")
        else:
            raise AssertionError(f"hostile mutation accepted: {name}")

main()
```
<!-- S2_GATE_TEST_END -->

Extraction and execution used:

```sh
sed -n '/^```python$/,/^```$/p' \
  doc/src/devdocs/musa-s2-metadata-gate-evidence.md |
  sed '1d;$d' |
  python3 - doc/src/devdocs/musa-s2-metadata-gate-evidence.md --self-test
```

The canonical test and all seven hostile rejections exited 0. This is an
intent test for this evidence gate, not a Julia or MUSA runtime test.

## Smallest next frontier

The result remains at `SX/NO_GO`. The first acquisition request is the exact
MUSA 5.2.0 archive plus vendor checksum/signature and authoritative complete
manifest, delivered through an approved offline channel. Even after T02, the
remaining failed rows must be closed in order without fallback, including an
explicit supported-host matrix, driver/device compatibility identities, a
vendor-to-Julia LLVM bridge, the complete ABI fields, a maintained locked
Julia package, and the license/redistribution record. A successor must replay
all 38 applicable rows again; it may not validate only the newly supplied
field. No compile, link, runtime, support, or readiness claim is authorized by
this receipt.
