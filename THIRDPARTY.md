The julia-musa project is licensed under the MIT License (see LICENSE.md).
julia-musa is a MUSA port of the [Julia language](https://github.com/JuliaLang/julia).
The "language" consists of the compiler (the contents of `src/`), most of the
standard library (`base/` and `stdlib/`), some utilities (most of the rest of
the files in this repository), and the experimental MUSA adapter under
`contrib/musa/`. See below for exceptions.

This file lists third-party software used by julia-musa. A copy of julia-musa
that includes this file does not necessarily use all the open source software
packages referred to below and may also only use portions of a given package.
Moore Threads has not modified the third-party components listed here.

## Inherited from Julia

The following entries are taken from upstream Julia
[`THIRDPARTY.md`](https://github.com/JuliaLang/julia/blob/master/THIRDPARTY.md).
They apply when the Julia source tree is built or redistributed as a complete
language. The MUSA adapter in `contrib/musa/` does not itself call these
libraries, and they are not extra attachments that must be uploaded with the
git source tree (except for the in-tree fragments named below).

- [crc32c.c](https://stackoverflow.com/questions/17645167/implementing-sse-4-2s-crc32c-in-software) (CRC-32c checksum code by Mark Adler) [[ZLib](https://opensource.org/licenses/Zlib)].
- [dl-cache.h](https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html) (for reading ld-cache files on startup) [LGPL2.1+]
- [LDC](https://github.com/ldc-developers/ldc/blob/master/LICENSE) (for ccall/cfunction ABI definitions) [BSD-3]. The portion of code that Julia uses from LDC is [BSD-3] licensed.
- [LLVM](https://releases.llvm.org/3.9.0/LICENSE.TXT) (for parts of src/disasm.cpp) [UIUC]
- [NetBSD](https://www.netbsd.org/about/redistribution.html) (for setjmp, longjmp, and strptime implementations on Windows) [BSD-3]
- [Python](https://docs.python.org/3/license.html) (for strtod implementation on Windows) [PSF]
- [FEMTOLISP](https://github.com/JeffBezanson/femtolisp) [BSD-3]

The following components included in Julia `Base` have their own separate licenses:

- base/ryu/* [Boost] (see [ryu](https://github.com/ulfjack/ryu/blob/master/LICENSE-Boost))
- base/special/{rem_pio2,hyperbolic}.jl [Freely distributable with preserved copyright notice] (see [FDLIBM](https://www.netlib.org/fdlibm))

The Julia language links to the following external libraries, which have their
own licenses:

- [LIBUNWIND](https://github.com/libunwind/libunwind/blob/master/LICENSE) [MIT]
- [LIBUV](https://github.com/JuliaLang/libuv/blob/julia-uv2-1.39.0/LICENSE) [MIT]
- [LLVM](https://releases.llvm.org/12.0.1/LICENSE.TXT) [APACHE 2.0 with LLVM Exception]
- [UTF8PROC](https://github.com/JuliaStrings/utf8proc) [MIT]

and optionally:

- [LibTracyClient](https://github.com/wolfpld/tracy/blob/master/LICENSE) [BSD-3]
- [ITTAPI](https://github.com/intel/ittapi/tree/master/LICENSES) [BSD-3 AND GPL2]

Julia's `stdlib` uses the following external libraries, which have their own licenses:

- [DSFMT](https://github.com/MersenneTwister-Lab/dSFMT/blob/master/LICENSE.txt) [BSD-3]
- [OPENLIBM](https://github.com/JuliaMath/openlibm/blob/master/LICENSE.md) [MIT, BSD-2, ISC]
- [GMP](https://gmplib.org/manual/Copying.html#Copying) [LGPL3+ or GPL2+]
- [LIBGIT2](https://github.com/libgit2/libgit2/blob/development/COPYING) [GPL2+ with unlimited linking exception]
- [CURL](https://curl.haxx.se/docs/copyright.html) [MIT/X derivative]
- [LIBSSH2](https://github.com/libssh2/libssh2/blob/master/COPYING) [BSD-3]
- [OPENSSL](https://www.openssl.org/source/license.html) [Apache 2.0]
- [MPFR](https://www.mpfr.org/mpfr-current/mpfr.html#Copying) [LGPL3+]
- [OPENBLAS](https://raw.github.com/xianyi/OpenBLAS/master/LICENSE) [BSD-3]
- [LAPACK](https://netlib.org/lapack/LICENSE.txt) [BSD-3]
- [PCRE](https://www.pcre.org/licence.txt) [BSD-3]
- [SUITESPARSE](https://github.com/DrTimothyAldenDavis/SuiteSparse/blob/master/LICENSE.txt) [mix of BSD-3-Clause, LGPL2.1+ and GPL2+; see individual module licenses]
  - [`libamd`](https://github.com/DrTimothyAldenDavis/SuiteSparse/blob/dev/AMD/Doc/License.txt) [BSD-3-Clause]
  - [`libcamd`](https://github.com/DrTimothyAldenDavis/SuiteSparse/blob/dev/CAMD/Doc/License.txt) [BSD-3-Clause]
  - [`libccolamd`](https://github.com/DrTimothyAldenDavis/SuiteSparse/blob/dev/CCOLAMD/Doc/License.txt) [BSD-3-Clause]
  - [`libcolamd`](https://github.com/DrTimothyAldenDavis/SuiteSparse/blob/dev/COLAMD/Doc/License.txt) [BSD-3-Clause]
  - [`libsuitesparseconfig`](https://github.com/DrTimothyAldenDavis/SuiteSparse/blob/dev/SuiteSparse_config/README.txt) [BSD-3-Clause]
  - [`libbtf`](https://github.com/DrTimothyAldenDavis/SuiteSparse/blob/dev/BTF/Doc/License.txt) [LGPL-2.1+]
  - [`libklu`](https://github.com/DrTimothyAldenDavis/SuiteSparse/blob/dev/KLU/Doc/License.txt) [LGPL-2.1+]
  - [`libldl`](https://github.com/DrTimothyAldenDavis/SuiteSparse/blob/dev/LDL/Doc/License.txt) [LGPL-2.1+]
  - [`libcholmod`](https://github.com/DrTimothyAldenDavis/SuiteSparse/blob/dev/CHOLMOD/Doc/License.txt) [LGPL-2.1+ and GPL-2.0+]
  - [`librbio`](https://github.com/DrTimothyAldenDavis/SuiteSparse/blob/dev/RBio/Doc/License.txt) [GPL-2.0+]
  - [`libspqr`](https://github.com/DrTimothyAldenDavis/SuiteSparse/blob/dev/SPQR/Doc/License.txt) [GPL-2.0+]
  - [`libumfpack`](https://github.com/DrTimothyAldenDavis/SuiteSparse/blob/dev/UMFPACK/Doc/License.txt) [GPL-2.0+]
- [LIBBLASTRAMPOLINE](https://github.com/staticfloat/libblastrampoline/blob/main/LICENSE) [MIT]
- [NGHTTP2](https://github.com/nghttp2/nghttp2/blob/master/COPYING) [MIT]

Julia's build process uses the following external tools:

- [PATCHELF](https://github.com/NixOS/patchelf/blob/master/COPYING) [GPL3]
- [OBJCONV](https://www.agner.org/optimize/#objconv) [GPL3]
- [LIBWHICH](https://github.com/vtjnash/libwhich/blob/master/LICENSE) [MIT]

Julia bundles the following external programs and libraries:

- [7-Zip](https://www.7-zip.org/license.txt)
- [ZLIB](https://zlib.net/zlib_license.html)
- [ZSTD](https://github.com/facebook/zstd/blob/v1.5.7/LICENSE)

On some platforms, distributions of Julia contain SSL certificate authority certificates,
released under the [Mozilla Public License](https://en.wikipedia.org/wiki/Mozilla_Public_License).

## Added by the julia-musa MUSA adapter

The isolated package under `contrib/musa/` is not part of Julia's normal build.
It records a fail-loud MTGPU target contract and an optional native launcher.
The following third-party packages are declared or invoked by that adapter.
They are resolved from the Julia package registry or provided by an installed
MUSA toolkit; they are not vendored into this source tree.

The `contrib/musa` adapter uses the following Julia packages, which have their
own licenses:

- [GPUCompiler.jl](https://github.com/JuliaGPU/GPUCompiler.jl/blob/master/LICENSE.md) [MIT]. Direct dependency of `MUSATargetAdapter` (`contrib/musa/Project.toml`; S5 pins 2.1.1, S6 pins 0.26.2).
- [LLVM.jl](https://github.com/maleadt/LLVM.jl/blob/master/LICENSE.md) [MIT]. Direct dependency of `MUSATargetAdapter` (`contrib/musa/Project.toml`; S5 pins 9.11.0, S6 pins 6.6.0).
- [LLVMExtra_jll](https://github.com/JuliaBinaryWrappers/LLVMExtra_jll.jl) [MIT]. JLL used by LLVM.jl (S5 0.0.44+0, S6 0.0.29+0). Not imported directly by the adapter sources.

The optional native launcher (`contrib/musa/s7-tooling`) links against a
locally installed MUSA runtime (`-lmusa`, `#include <musa.h>`) and the S6
object route may invoke vendor `llc` / `llvm-dis` / `llvm-objdump` from
MUSA Toolkit 5.2.0. Those vendor files are not distributed with this source
repository.

GPUCompiler.jl's package closure may also resolve supporting packages such as
CEnum, ExprTools, CompilerCaching, Highlights, TreeSitter, and Tracy. Those
are transitive registry dependencies, not direct adapter imports, and are not
listed separately here.
