# MUSA S3 authorized dependency-acquisition receipt

## Decision

This receipt was produced by Gluon task
`c5f7b86f-869b-40e0-8be8-b52d6d415a00` from the exact accepted S2
independent-review result `2f7dfae1415867c7b9ce688ef55818134b266d08`.

**NO_GO.** The Julia tool gap and the MUSA authority gate have separate
results:

| Path | Result | Consequence |
|---|---|---|
| Official workspace-local Julia | PASS | Julia 1.12.6 was authenticated, installed, and executed. |
| Previously blocked source-format gate | FAIL | `make fix-whitespace` ran and reported two pre-existing tabs in an accepted predecessor receipt. |
| Complete authoritative MUSA Toolkit 5.2.0 evidence set | NO_GO | The first required authority, the complete original vendor archive, was not obtainable from the reachable vendor publication channels. Its vendor checksum, detached signature/key chain, and authoritative complete per-file manifest were also unavailable. |

The Julia success does not weaken MUSA T02. The frozen S2 denominator remains
40 fields, 38 applicable, with predecessor accounting **P=11, F=27, S=0,
I=0, N=2** and T02 as its first failure. Those values identify the accepted
input; they are not a new 38-field replay. Because the atomic T02 input was
incomplete, this task did not replay the full denominator and did not enter
the bounded CPU implementation frontier. No field moved, and no
implementation, build, runtime, GPU, support, compatibility, or readiness
claim is made.

Commands were CPU-only with `OMP_NUM_THREADS=2` and `MAKEFLAGS=-j2`. No host
package install, credentials, services, database, driver or device query,
GPU, artifact publication, cleanup, deletion, move, rename, overwrite, push,
deploy, or formal review occurred. Technical completion is not formal
acceptance.

## Inputs and immediate Julia callers

The task began with an empty detached worktree at the required commit. The
accepted S2 subject and review were read in full and had SHA-256 identities:

```text
6ae8a3515fac538136d7bb50569a259f3e948ee7e8a09a8675a956416acd8c2a  doc/src/devdocs/musa-s2-metadata-gate-evidence.md
ea0e3effaf335a51aaf15498a9e5dbf882aafbd4072cba351e857fd05eb70dd0  doc/src/devdocs/reviews/musa-s2-full-metadata-gate-independent-review.md
```

`VERSION`, SHA-256
`67748745dc1cdfc14f370c7be0266cdc3d32386d3b9ebafec2e47d9f58ce5d61`,
declares `1.14.0-DEV`. The immediate format-gate callers are Makefile lines
174--185, which pipe tracked paths to `julia
contrib/check-whitespace.jl --stdin` and add `--fix` for `fix-whitespace`.
Their identities were:

```text
8f8a6c499bc4fd4023f5db7a3a44ee6ca56957e09869cc2bc3272b2a4bff3d06  Makefile
312605c6fefeed042d0dc74b5d7d7f53c68d56bce86ce2c28e3054d3af0d743c  Make.inc
a6c913345e39138ebcdf71d5ea23e92917fe0bdf3d1397e81d62c439f4e915a9  contrib/check-whitespace.jl
```

The checkout has no built `usr/bin/julia`. The official Julia manual-download
page identified 1.12.6 as the current stable release and linked the Linux
x86-64 binary, checksum list, detached signature, and Julia release key used
below. A stable 1.x Julia is sufficient to execute this target-neutral format
script; it is not represented as a binary built from the 1.14 development
checkout.

## Retained root and chronological Julia acquisition

All fetched and installed bytes are retained under the fresh root
`/workspace/.gluon-c5f7b86f-s3-20260803T083206Z`. HTTP response headers are
retained beside each download and include server dates, validators, and final
content lengths.

1. At `2026-08-03T08:32:34Z`, the official checksum list was fetched from
   `https://julialang-s3.julialang.org/bin/checksums/julia-1.12.6.sha256`:
   HTTP 200, zero redirects, final URL unchanged, 1,309 bytes, SHA-256
   `d44a6138f428b7a4cd4d4e6d0aba53bbf380d3279e575bfb743f668b7f88190f`.
2. At `2026-08-03T08:32:35Z`, the official archive URL
   `https://julialang-s3.julialang.org/bin/linux/x64/1.12/julia-1.12.6-linux-x86_64.tar.gz`
   returned HTTP 200 with zero redirects. The initial transfer and two range
   resumes overlapped after the command runner yielded. The resulting
   retained 314,196,344-byte file failed the published checksum and has
   SHA-256
   `37aa025cbecb7ebc3027506eb20844e06e1b27fb077f722460a8a33cb9d10a85`.
   It was rejected, not hidden or used.
3. A fresh file was fetched from the same unchanged archive URL. It completed
   with HTTP 200, zero redirects, 289,794,236 bytes, and 79.571315 seconds.
   Its SHA-256 is
   `bbabf3bef19421a9dbd24a767d807606ab85e444323b5a1c73ffe293fa3d079a`,
   exactly the value published in the official checksum list.
4. At `2026-08-03T08:34:29Z`, the detached signature was fetched from the
   archive URL plus `.asc`: HTTP 200, zero redirects, unchanged final URL,
   833 bytes, SHA-256
   `739c2a114eefa0004675232f9288f0061a91b1d6daba3730245903482d643cf1`.
   At the same timestamp, the key linked by the Julia download-verification
   page was fetched from `https://julialang.org/assets/juliareleases.asc`:
   HTTP 200, zero redirects, unchanged final URL, 3,112 bytes, SHA-256
   `a27705bf1e5a44d1905e669da0c990ac2d7ab7c13ec299e15bacdab5dcbb8d13`.
5. At `2026-08-03T08:40:02Z`, checksum verification again reported equal
   expected and actual values. Offline GPG verification reported `GOODSIG`
   and `VALIDSIG` for primary fingerprint
   `3673DF529D9049477F76B37566E3C7DC03D6E495`, Julia binary-signing identity
   `Julia (Binary signing key) <buildbot@julialang.org>`, and signature time
   `2026-04-10T03:53:28Z`. The key's certification trust was undefined in the
   fresh keyring; its provenance is instead the HTTPS key link on Julia's
   official verification page.
6. The verified archive was extracted only beneath `julia/install`. The
   installed executable is
   `julia/install/julia-1.12.6/bin/julia`, SHA-256
   `fd670aabc838e93f178cbcf7304c5e9c50aadcce3735e86d5e3218b1bb04e602`.
   Its exact version output was `julia version 1.12.6`.

With that executable first on `PATH`, the formerly blocked command was run:

```text
env OMP_NUM_THREADS=2 MAKEFLAGS=-j2 make fix-whitespace
Whitespace check found 2 issues:
doc/src/devdocs/reviews/musa-s1-metadata-inventory-correction-independent-review.md:52 -- tab
doc/src/devdocs/reviews/musa-s1-metadata-inventory-correction-independent-review.md:58 -- tab
make: *** [Makefile:185: fix-whitespace] Error 1
```

The outer command exited 2. The two tabs are inside accepted predecessor
evidence, and the script's fixer only rewrites leading indentation tabs, so
the command made no tracked change. This is an executed gate failure, not a
missing-Julia or skipped-gate result.

## Chronological MUSA authority acquisition attempt

Only vendor-published Moore Threads endpoints were queried. An installed
tree, packages, filenames, locally generated hashes, and partial manifests
were never treated as distribution authority.

1. At `2026-08-03T08:37:47Z`, the repository configuration package linked by
   the vendor's MUSA 5.2.0 installation guide was fetched from
   `https://dl.mthreads.com/repo/repository/ubuntu2204/pool/jammy/amd64/musa-repo-jammy_1.0.0.11-1_all.deb`:
   HTTP 200, zero redirects, unchanged final URL, 3,288 bytes, SHA-256
   `09577a0c1d613753e82e972e34c222a1c7bdcc0b444bb23ad71ae395e8ba61be`.
   It identifies vendor maintainer `musatools <developers@mthreads.com>`,
   source `https://dl.mthreads.com/repo/repository/ubuntu2204/ jammy main`,
   and ships a repository keyring. It was extracted beneath the retained
   root; it was not installed on the host.
2. At `2026-08-03T08:38:08Z`, that source's `dists/jammy/InRelease` and
   `main/binary-amd64/Packages.gz` were fetched: both HTTP 200 with zero
   redirects and unchanged final URLs. Sizes and SHA-256 values were 3,562 /
   `210a9491048eae7b208bf5bf62496a4b4988944f4a01356cff2204406d6777c3`
   and 17,085 /
   `f70967631c6376e3d4f429fc510db2ff31c787b11cd390c4804f35fc39bdcb8e`.
   The index lists 5.2.0 APT metapackages and components, not the original
   complete `musa_toolkits_5.2.0.tar.gz` distribution and not an authoritative
   complete per-file distribution manifest.
3. The shipped keyring has primary fingerprint
   `5C804CAE420AFCC0BDD28FECEE9B8BE860C98FEF`. At
   `2026-08-03T08:40:05Z`, `gpgv` against that keyring exited 1 and reported
   `BAD signature from "musatools <developers@mthreads.com>"` for the
   `InRelease` signature made with key ID `EE9B8BE860C98FEF`. Although the
   fetched package index's SHA-256 matches the value inside that InRelease,
   the failed signature prevents promotion of the index to authenticated
   authority.
4. At `2026-08-03T08:38:37Z`, the authoritative installation guide was
   retained from
   `https://docs.mthreads.com/en/musa-sdk/musa-sdk-doc-online/install_guide/`:
   HTTP 200, zero redirects, unchanged final URL, 171,631 bytes, SHA-256
   `5ea9c9e9a487a63244fb31de0252c228bd988ca5a9079e296a8e4889e7b23afd`.
   It names `musa_toolkits_5.2.0.tar.gz` in an example offline layout and
   extraction command but supplies no hyperlink for that archive and no
   vendor checksum, detached signature/key chain, or authoritative complete
   per-file manifest for it.
5. At `2026-08-03T08:39:16Z`, the exact documented archive name was queried
   through the vendor repository's artifact-search API:
   `https://dl.mthreads.com/repo/api/search/artifact?name=musa_toolkits_5.2.0.tar.gz`.
   It returned HTTP 200, zero redirects, unchanged final URL, 14 bytes, and
   exact body `{"results":[]}` (SHA-256
   `5021e624e752b001ce3e3846e8f158ed4aeb93a4c9a72fdb35a0c5b14a0eea84`).

The exact first missing authority is therefore the byte-for-byte complete
original vendor MUSA Toolkit 5.2.0 archive for an identified supported host
tuple. Since that archive is unavailable, no vendor checksum can be bound to
it; no detached archive/checksum signature and verification chain was
obtainable; and no complete authoritative manifest enumerating every path,
entry type, mode, link target, size, and digest was obtainable. The bad APT
repository signature is an additional authenticated-channel failure, not a
substitute for or reordering of the first T02 requirement.

## Frozen successor

The smallest honest successor remains `SX/NO_GO` at T02. It requires one
owner-identified, atomic vendor evidence set satisfying the accepted S2
five-part offline artifact contract: complete archive, vendor-published
checksum, detached signature plus pinned verification chain, complete
release-bound per-file manifest, and release/host/acquisition provenance.
Only after that set is complete may a successor replay all 38 applicable rows
and consider the bounded CPU implementation frontier. Julia need not be
reacquired while this retained authenticated installation remains intact,
but its successful installation grants no MUSA authority.
