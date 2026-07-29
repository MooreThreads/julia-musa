# Julia on MUSA: scope and dependency research

## Status, identity, and decision

This document is a **research candidate for independent review**, not an
implementation plan or a report of a working port. It records facts visible in
one upstream Julia checkout and separates them from hypotheses that require
MUSA-specific evidence.

**FACT — frozen repository identity.** The inspected repository root was
`/workspace`, `origin` was `git@github.com:JuliaLang/julia.git`, `HEAD` was the
detached commit `cc2f404a962ed06520a5e73493e5b84217bbf6f5`, its tree was
`1ee298c699293b8ba633ce407997cab6891e5554`, and [`VERSION`](../../../VERSION)
contained `1.14.0-DEV`. The starting worktree was clean. No earlier task
worktree, result commit, or continuation state was read, mounted, reused, or
derived from.

**Decision.** The smallest evidence-producing route starts outside Julia core:
first establish a MUSA package/toolchain inventory, then prove that an external
Julia GPU package can lower one kernel through Julia's existing external
compiler interface. Runtime discovery, device intrinsics, MUSA API bindings,
kernel launch, arrays, device libraries, and toolkit artifacts presumptively
belong to that external package. A Julia-core change is in scope only after a
minimal external-package reproducer demonstrates a missing or incorrect
general-purpose Julia compiler/runtime interface. This boundary follows the
repository's own classification of CUDA.jl, AMDGPU.jl, and oneAPI.jl as
external packages and its explicit description of GPUCompiler.jl as an
external codegen consumer
([`doc/src/manual/distributed-computing.md`](../manual/distributed-computing.md),
[`src/aotcompile.cpp`](../../../src/aotcompile.cpp)).

Labels in this document have strict meanings:

- **FACT** is supported by a tracked file at the frozen commit or by a recorded
  read-only command.
- **HYPOTHESIS** is a proposed explanation or ownership assignment that still
  needs MUSA evidence.
- **BLOCKER** is evidence missing before the next decision can be made.
- **EXCLUSION** is work intentionally not performed by this research task.

## What Julia builds

**FACT — top-level dependency order.** The default target selects a release or
debug build. `julia-deps` delegates to `deps`; `julia-stdlib` depends on those
dependencies; `julia-src-*` builds the runtime after dependencies, the
FemtoLisp boot image, and the CLI; `julia-sysimg-*` then depends on runtime,
top-level Julia packages, stdlibs, Base, and CLI. The final `julia-*` target
also creates the executable link and small runtime test libraries, while the
top-level release/debug target builds stdlib package caches
([`Makefile`](../../../Makefile)).

**FACT — bootstrap stages.** The system-image rules make the compiler sources
from `base/` and `Compiler/src` into `basecompiler`; use that image to process
the remaining Base, frontend, and stdlib sources into `sysbase`; then use
`sysbase` plus generated precompile statements to emit the final `sys` image.
Each image archive is linked into a shared library by the host C++ linker.
JuliaLowering has a further optional `sys-JL` image stage
([`sysimage.mk`](../../../sysimage.mk)). The architectural description agrees:
Julia identifies methods by executing code, creates LLVM modules, serializes
bitcode/object/assembly archives, and invokes a linker; a native compiler
driver links system images, while LLD links package images
([`doc/src/devdocs/aot.md`](aot.md)).

The resulting dependency shape relevant to this investigation is:

```text
host tools + downloaded/cached binary or source dependencies
    -> CLI + FemtoLisp boot image + libjulia runtime/codegen
    -> basecompiler image
    -> sysbase image
    -> final sys image
    -> stdlib package caches and Julia test harness

existing host Julia + GPUCompiler-style external package
    -> target-specific device IR/code object
    -> vendor device link/load/launch path
```

The second line is deliberately not asserted to be part of Julia's own
bootstrap.

## LLVM and codegen assumptions

**FACT.** This base pins Julia's LLVM fork at `21.1.8` /
`julia-21.1.8-0` and names `libLLVM` JLL version `21.1.8+0`
([`deps/llvm.version`](../../../deps/llvm.version)). The source-build defaults
set LLVM targets to `host;NVPTX;AMDGPU;WebAssembly;BPF;AVR`; there is no MUSA
target in that list ([`deps/llvm.mk`](../../../deps/llvm.mk)). Julia's C++
runtime/codegen obtains headers, compile flags, libraries, and target
information through `LLVM_CONFIG_HOST`, and links `libjulia-codegen` against
LLVM ([`src/Makefile`](../../../src/Makefile),
[`Make.inc`](../../../Make.inc)).

**FACT.** `JULIA_CPU_TARGET` configures CPU machine-code image generation and
multiversioning, not a GPU-package backend. Julia's AOT documentation describes
it in terms of CPU features and the image loader
([`doc/src/devdocs/aot.md`](aot.md),
[`doc/src/devdocs/sysimg.md`](sysimg.md),
[`doc/src/manual/environment-variables.md`](../manual/environment-variables.md)).
It should therefore not be treated as a MUSA-enablement switch.

**FACT.** Julia exposes reusable, target-neutral seams. `jl_emit_native_impl`
can fill a supplied LLVM module and is explicitly documented in source as
usable by external consumers such as GPUCompiler.jl
([`src/aotcompile.cpp`](../../../src/aotcompile.cpp)). `Compiler` supports
custom `AbstractInterpreter` implementations and overlay method tables; its
tests contain GPUCompiler/CUDA regression cases
([`Compiler/src/types.jl`](../../../Compiler/src/types.jl),
[`Compiler/test/AbstractInterpreter.jl`](../../../Compiler/test/AbstractInterpreter.jl)).
Base also describes extensible non-CPU address spaces whose exact semantics
belong to a specific backend
([`base/genericmemory.jl`](../../../base/genericmemory.jl)).

**HYPOTHESIS.** If MUSA 5.2.0 accepts an IR, object, or CUDA-compatible input
that an external package can produce using the existing Julia/LLVM interfaces,
no Julia-core or Julia-LLVM build change is needed. If MUSA instead requires an
LLVM target unavailable in Julia's pinned LLVM, the first owner may be the
MUSA toolchain or an LLVM integration layer. Julia's LLVM dependency becomes a
candidate owner only if the target must be compiled into the same LLVM used by
Julia and cannot be loaded or invoked externally. That escalation needs a
small reproducer; the absent target name alone is not enough.

## Core versus package ownership

| Concern | Presumptive owner | Evidence and escalation rule |
|---|---|---|
| MUSA driver/runtime API bindings, device enumeration, contexts, streams, memory, module loading, launch, synchronization, errors | External MUSA Julia package | Julia documents comparable CUDA/ROCm/oneAPI functionality as external packages ([`doc/src/manual/distributed-computing.md`](../manual/distributed-computing.md)). Escalate only for a general Julia FFI/runtime defect. |
| MUSA kernel target description, address spaces, intrinsics, ABI, device library linkage, code-object format | External MUSA backend package, GPUCompiler/LLVM integration as appropriate, and vendor toolchain | Base says non-CPU address-space semantics are backend-defined; direct target intrinsics have no Julia compatibility layer ([`base/genericmemory.jl`](../../../base/genericmemory.jl), [`doc/src/manual/calling-c-and-fortran-code.md`](../manual/calling-c-and-fortran-code.md)). |
| Shared target-independent inference and GPU compilation orchestration | GPUCompiler.jl or another external shared GPU layer | Julia provides custom-interpreter and native-emission seams and tests compatibility cases ([`Compiler/test/AbstractInterpreter.jl`](../../../Compiler/test/AbstractInterpreter.jl), [`src/aotcompile.cpp`](../../../src/aotcompile.cpp)). A Julia issue is justified only by a general seam failure. |
| CUDA-specific wrappers or behavior | CUDA.jl, not a MUSA implementation and not Julia core | The manual says CUDA.jl wraps CUDA libraries and compiles NVIDIA kernels ([`doc/src/manual/distributed-computing.md`](../manual/distributed-computing.md)). Reuse may be investigated, but compatibility is not assumed. |
| Host Julia bootstrap, GC, tasking, CPU JIT, system/package images | Julia core | These are the in-tree runtime and image pipeline ([`Makefile`](../../../Makefile), [`sysimage.mk`](../../../sysimage.mk), [`doc/src/devdocs/aot.md`](aot.md)). They enter MUSA scope only if an external reproducer isolates a generic defect. |
| Julia's pinned LLVM target set or exported codegen ABI | Julia core and Julia's LLVM fork, last | The build pins and links a patched LLVM and exports codegen entry points ([`deps/llvm.version`](../../../deps/llvm.version), [`deps/llvm.mk`](../../../deps/llvm.mk), [`src/Makefile`](../../../src/Makefile)). Require proof that external ownership cannot solve the problem. |

**HYPOTHESIS.** A CUDA.jl fork may be useful as a reading prototype because
the high-level concerns are analogous, but vendor API, ABI, toolchain, device
library, artifact, and license differences could make a clean MUSA package the
correct owner. This repository contains no source tree for CUDA.jl,
GPUCompiler.jl, AMDGPU.jl, oneAPI.jl, or a MUSA package, so that choice cannot
be settled here.

## Dependencies, downloads, host requirements, and tests

**FACT — dependency modes.** A first Julia build normally downloads prebuilt
external dependencies. `USE_BINARYBUILDER=0` switches to source builds for an
offline build only if the needed source inputs are already present
([`doc/src/devdocs/build/build.md`](build/build.md)). The dependency makefile
selects LLVM, LLD, libuv/unwind, BLAS, GMP/MPFR, TLS/network libraries,
SuiteSparse, compression libraries, and other components according to
`USE_SYSTEM_*` and BinaryBuilder settings, with `get`, `extract`, `configure`,
`compile`, `stage`, and `install` phases
([`deps/Makefile`](../../../deps/Makefile)). BinaryBuilder mode constructs a
platform-specific GitHub release URL, downloads a tarball into
`deps/srccache`, checks its checksum, extracts it, and writes an installed
manifest ([`deps/tools/bb-install.mk`](../../../deps/tools/bb-install.mk)).
Stdlib JLL metadata also has explicit download rules
([`stdlib/Makefile`](../../../stdlib/Makefile)).

**FACT — host tools.** The documented inputs include GNU make; GCC/G++ or
Clang; libatomic; Python; gfortran; Perl; a downloader; m4; awk; patch; CMake;
pkg-config; `which`; and diffutils. The same document warns that system-library
overrides add unvalidated version variability and that Julia expects its
patched LLVM and custom libuv
([`doc/src/devdocs/build/build.md`](build/build.md)). These are documentation
requirements, not proof that this host satisfies them.

**FACT — in-tree tests.** The top-level test target first requires a completed
Julia build. The test makefile dispatches named groups, including `compiler`
and `Compiler`, through `test/runtests.jl`; the standalone Compiler suite uses
`Base.runtests(["Compiler"])`
([`Makefile`](../../../Makefile), [`test/Makefile`](../../../test/Makefile),
[`Compiler/test/runtests.jl`](../../../Compiler/test/runtests.jl)). The
Compiler tests cover external-interpreter behavior relevant to GPUCompiler,
but this repository has no MUSA runtime integration suite
([`Compiler/test/AbstractInterpreter.jl`](../../../Compiler/test/AbstractInterpreter.jl)).

**BLOCKER — binary and artifact closure.** Before any offline build or package
test, an independent inventory must pin and locally verify every Julia build
tarball/JLL, package registry and source tree, GPUCompiler/LLVM package
artifact, MUSA toolkit component, device library, runtime library, and driver
interface needed by the chosen slice. A clean source checkout alone is not an
offline build closure.

## Missing MUSA 5.2.0 evidence

**FACT.** A case-insensitive tracked-content search for `musa`,
`moore[ _-]*threads`, or `mthreads` returned no match (exit `1`) at the frozen
base. This is evidence only that the inspected Julia tree contains no matching
tracked text.

The following are **BLOCKERS**, all currently unknown:

- the exact MUSA 5.2.0 distribution identifier, supported host distributions
  and architectures, compiler/linker names and versions, license, hashes, and
  offline installation layout;
- the installed driver version, supported devices and ISA/code-object
  compatibility matrix, runtime and driver ABI, and a real device inventory;
- whether the toolchain consumes LLVM IR/bitcode, a CUDA-derived format, an
  out-of-tree LLVM target, or only vendor-language input;
- kernel calling convention, address spaces, data layout, intrinsics, device
  library and math ABI, exception/error behavior, atomics, synchronization, and
  debug information requirements;
- a maintained Julia MUSA package (if one exists), its repository commit,
  Julia/GPUCompiler/LLVM compatibility bounds, artifacts, test matrix, and
  ownership contacts;
- legal permission and a reproducible source for redistributing toolkit or
  runtime artifacts.

No porting, compilation, linking, package loading, runtime, performance, or GPU
claim is made without this evidence.

## Future no-network CPU metadata/build preflight

This is a proposed successor, not a check executed here. It must run in a fresh
worktree at the same approved base, with network access administratively
disabled, no GPU assigned, and `OMP_NUM_THREADS=2`. It is read-only and should
produce a manifest containing:

1. `git rev-parse HEAD`, `git rev-parse HEAD^{tree}`, `git status
   --porcelain=v1 --untracked-files=all`, `git remote get-url origin`, and
   `git diff --check`, with exact exits.
2. `uname -a` and the path plus `--version` output for the documented host
   tools. Version commands must not install, update, or configure anything.
3. Presence, size, and cryptographic digest of every pre-approved cached input
   from the binary/artifact closure. Absence is a hard `NO_GO`; the preflight
   must not try a download.
4. A static resolution table mapping each selected Julia dependency and
   external-package dependency to either an approved system installation or a
   verified cache object. No `make`, Julia, package manager, compiler, linker,
   or vendor executable is run in this preflight.
5. A written go/no-go assessment. `GO` means only “the declared later build
   slice has a complete, pinned offline input set”; it does not mean Julia or
   MUSA works.

Avoid `make -n` as evidence: included makefiles evaluate shell expressions
during parsing, and a dry run neither proves that inputs are offline-complete
nor that compilation will succeed
([`Make.inc`](../../../Make.inc), [`deps/Makefile`](../../../deps/Makefile)).

## Smallest later slices

Each slice requires separate authorization and retains the frozen dependency
denominator below.

1. **Metadata-only MUSA/toolchain closure (CPU, no Julia execution).** Resolve
   the blockers above from vendor and external-package sources; pin hashes and
   compatibility; independently review ownership. Stop on ambiguity.
2. **Compile-only external-package slice (CPU, no GPU).** Using an existing
   trusted host Julia and a locked external environment, compile exactly one
   side-effect-free integer kernel through the prospective MUSA backend and
   preserve typed IR, target LLVM IR, vendor input, compiler diagnostics, and
   output-object metadata. Do not rebuild Julia. Success is only a
   well-formed target object according to an independently identified vendor
   inspection tool.
3. **Single-object device-link slice (CPU, no GPU).** Link that one object with
   only the minimum pinned device/runtime libraries, preserve the full link
   line and symbol/metadata inventory, and reject undeclared host or network
   inputs.
4. **One-kernel package integration (one assigned GPU).** Load, launch,
   synchronize, copy back, and validate only the frozen correctness oracle
   below. No performance claim and no Julia rebuild.
5. **Core escalation, conditional.** Only if slices 2–4 fail with a minimized
   reproducer at a documented Julia seam, classify the defect as (a) external
   MUSA package, (b) GPUCompiler/shared GPU layer, (c) Julia's LLVM fork/build,
   or (d) Julia compiler/runtime. Open the smallest owner-specific successor.

The smallest useful compile/link evidence is slices 2 and 3—not a Julia build
and not a broad CUDA compatibility test.

## Runtime/correctness oracle and frozen denominator

The representative oracle is a bounds-sensitive, deterministic integer kernel:
for `N = 257`, launch enough threads for at least two workgroups and compute
only indices `1:N`:

```text
x[i]   = UInt32(i)
y[i]   = UInt32(2*i + 1)
out[i] = UInt32(3) * x[i] + y[i]
```

Allocate guard regions before and after `out`, initialized to
`0xdeadbeef`. After explicit synchronization and a device-to-host copy, require
exact equality of all 257 outputs to the host formula and exact preservation
of both guards. Also require that every driver/runtime/compiler call returns
success and that the launched device is the recorded assigned MUSA device.
This exercises external compilation, indexing, launch geometry, memory
transfer, synchronization, and bounds behavior without floating-point
tolerance ambiguity. It is a proposed external-package oracle, not an in-tree
Julia test.

Freeze before execution:

- Julia repository commit and tree;
- host Julia binary version/build commit and digest;
- complete package `Project.toml`/`Manifest.toml`, registries, source commits,
  and artifact hashes;
- GPUCompiler, LLVM.jl, and prospective MUSA package commits;
- MUSA 5.2.0 exact build, every toolkit/runtime/device-library digest, driver
  version, device model/UUID/ISA, firmware if reportable, and host OS/kernel;
- compiler and linker commands, environment allowlist, launch dimensions,
  oracle source, inputs, guards, and expected output digest.

Any denominator change creates a new result; it must not be compared as if it
were a rerun.

## Risks and unknowns

- **HYPOTHESIS — backend availability risk.** MUSA may require an unavailable
  LLVM backend or vendor compiler path. The in-tree target list proves only
  absence from Julia's source-build defaults
  ([`deps/llvm.mk`](../../../deps/llvm.mk)).
- **HYPOTHESIS — CUDA resemblance risk.** Source or API similarity may not
  imply ABI, intrinsic, device-library, or semantic compatibility. Julia's
  documentation explicitly says target intrinsics have no compatibility layer
  ([`doc/src/manual/calling-c-and-fortran-code.md`](../manual/calling-c-and-fortran-code.md)).
- **FACT — patched LLVM coupling.** Julia warns that unpatched or different
  LLVM versions can cause errors or poor performance
  ([`doc/src/devdocs/build/build.md`](build/build.md)). Replacing Julia's LLVM
  is therefore a high-cost, last-resort experiment.
- **FACT — bootstrap cost is irrelevant until core ownership is proven.**
  Julia's runtime/system-image pipeline is downstream of a large dependency
  graph ([`Makefile`](../../../Makefile), [`sysimage.mk`](../../../sysimage.mk)).
  Building it before an external compile-only proof would spend resources
  without resolving the primary boundary.
- **HYPOTHESIS — package compatibility risk.** GPUCompiler and LLVM.jl may
  constrain Julia and LLVM versions more narrowly than a future MUSA package.
  This repository does not carry their manifests, so only an external locked
  environment can resolve the matrix.
- **BLOCKER — hardware and legal risk.** No device, driver, toolkit inventory,
  redistributability evidence, or MUSA 5.2.0 documentation was inspected.

## Prioritized successor DAG

```text
S0 independent review of this scope document
 |
 v
S1 vendor MUSA 5.2.0 + external Julia-package metadata inventory
 |
 v
S2 pinned artifact/source closure and no-network CPU preflight
 |
 +------------------------------+
 |                              |
 v                              v
S3 external compile-only        SX stop: unresolved ABI/license/input gap
 |
 v
S4 minimal device link
 |
 v
S5 one-GPU frozen oracle
 |
 +-------------------+--------------------+
 |                   |                    |
 v                   v                    v
S6 package tests   S7 shared GPU seam   S8 Julia-core/LLVM reproducer
and hardening      reproducer           (only if isolated there)
 |                   |                    |
 +-------------------+--------------------+
                     |
                     v
              S9 broader correctness,
              portability, then performance
```

Priority is `S0 -> S1 -> S2 -> S3 -> S4 -> S5`. `S6` follows a passing oracle.
`S7` or `S8` follows only a minimized failure assigned to that owner. Any
missing exact toolkit input, unclear license, unexpected network request, or
denominator drift routes to `SX`, not to an opportunistic build.

## Exclusions and evidence log

**EXCLUSION.** This task did not fetch; install; update dependencies; create a
`Make.user`; configure; invoke `make`; build; execute Julia; call a compiler,
linker, package manager, or vendor tool; use a GPU; edit existing files or
source; mutate external services, credentials, reviews, or databases; clean;
reset; amend; push; or deploy. `OMP_NUM_THREADS=2` was set on allowed metadata
commands. The only intended repository change is this document.

The identity/negative-search evidence was captured with this read-only command
block; the printed `EXIT` values are the true exit of each named command:

```sh
set +e
run_check() {
    label=$1
    shift
    OMP_NUM_THREADS=2 "$@"
    rc=$?
    printf 'EXIT %s %s\n' "$rc" "$label"
}
run_check root git rev-parse --show-toplevel
run_check head git rev-parse HEAD
run_check tree git rev-parse 'HEAD^{tree}'
run_check clean git status --porcelain=v1 --untracked-files=all
run_check origin git remote get-url origin
run_check branch git branch --show-current
run_check version sed -n '1p' VERSION
run_check musa_tracked_search git grep -n -i -E 'musa|moore[[:space:]_-]*threads|mthreads'
run_check gpu_package_paths git ls-files '*GPUCompiler*' '*CUDA*' '*AMDGPU*' '*oneAPI*'
exit 0
```

Recorded output:

```text
/workspace
EXIT 0 root
cc2f404a962ed06520a5e73493e5b84217bbf6f5
EXIT 0 head
1ee298c699293b8ba633ce407997cab6891e5554
EXIT 0 tree
EXIT 0 clean
git@github.com:JuliaLang/julia.git
EXIT 0 origin
EXIT 0 branch
1.14.0-DEV
EXIT 0 version
EXIT 1 musa_tracked_search
EXIT 0 gpu_package_paths
```

The blank `clean` and `branch` payloads mean a clean worktree and detached
HEAD. The blank package-path payload means the pathspecs found no tracked
package source paths; it does not prove those external repositories do not
exist.

Research used only `git`, `rg`, `sed`, and tracked files. The shell invocations
that grouped the source-reading commands each exited `0`; individual commands
inside those earlier groups were not instrumented separately, which is a
logging limitation rather than project evidence. Final one-path, whitespace,
ancestry, and cleanliness checks are recorded after the research commit in the
task result because a commit cannot contain evidence about its own final hash.
