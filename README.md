# Julia MUSA

Julia MUSA is a Moore Threads maintained porting line of the Julia language
source tree for work with MUSA-enabled toolchains. It keeps the upstream Julia
layout and language implementation while providing an isolated MUSA target
adapter under `contrib/musa/`.

## Source and version

- Upstream project: [JuliaLang/julia](https://github.com/JuliaLang/julia)
- Inherited source version: `1.14.0-DEV`
- Upstream baseline: `6d9430a62c98680bacc98f8068cb0c93fd1ffaae`
- Moore Threads publication line: `musa-v1.14.0-DEV`

The baseline identifies the upstream source from which the MUSA work was
carried forward. Upstream history, source attribution, and the original Julia
directory structure remain available in this repository.

## MUSA adaptation

The MUSA work adds a separately scoped Julia package and target adapter in
`contrib/musa/`. It records the target naming, module ABI checks, and the
integration points needed by a MUSA-aware compiler toolchain. Small compiler
and runtime-facing changes retain the existing CPU and other upstream paths;
the MUSA code is selected explicitly rather than replacing those paths.

The adapter is intentionally kept beside the main Julia build so that its
dependencies and future backend work can evolve independently. See
[`contrib/musa/README.md`](contrib/musa/README.md) for the adapter contract and
the source-level commands used by that package.

## Dependencies

A normal Julia build uses the compilers, linker, libraries, and build tools
listed in the upstream [build documentation](https://github.com/JuliaLang/julia/blob/master/doc/src/devdocs/build/build.md).
The MUSA adapter additionally uses the Julia package environment declared in
`contrib/musa/Project.toml` and `contrib/musa/Manifest.toml`. A MUSA-capable
toolchain must be supplied separately; this repository does not bundle a MUSA
runtime or vendor SDK.

## Build and use

Clone the publication branch and follow the upstream build prerequisites:

```sh
git clone https://github.com/MooreThreads/julia-musa.git
cd julia-musa
git checkout musa-v1.14.0-DEV
make -j2
```

The resulting `julia` executable can be started from the repository root:

```sh
./julia
```

To work on the adapter package, enter `contrib/musa/`, instantiate its Julia
environment, and use the package commands documented in its README. Keep the
main Julia build and the adapter environment separate when changing backend
tooling.

## Repository layout

- `src/`, `base/`, and `Compiler/` — Julia language and compiler sources.
- `stdlib/` — standard-library packages shipped with Julia.
- `contrib/musa/` — Moore Threads MUSA adapter package and tooling.
- `doc/` — inherited Julia documentation and developer material.
- `test/` — inherited source and compiler tests.

## Contributions and attribution

Contributions should preserve upstream Julia interfaces and should include
focused documentation for any MUSA-specific behavior. Please read
[`CONTRIBUTING.md`](CONTRIBUTING.md) and the upstream contribution guidance
before opening an issue or pull request. Julia remains the upstream project;
Moore Threads maintains this MUSA publication line and its adapter changes.

The root [`LICENSE`](LICENSE) contains the publication declaration and the
applicable upstream license text. Additional notices in the source tree remain
with the components to which they apply.
