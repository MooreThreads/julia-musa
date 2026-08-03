# Independent review of MUSA S3 authorized dependency acquisition

## Scope and decision

This receipt was produced by Gluon task
`90c5fe1f-4b4e-4a05-aafd-accdef4a1bd6`. It independently reviews task
`c5f7b86f-869b-40e0-8be8-b52d6d415a00`, attempt
`ae9e6f98-acdd-4462-a465-316b5e813f4c`, candidate
`ede1c798-215d-4cc1-8661-2be2a9792fb4`, and exact S3 result
`2c2197f65b100f90b41da894b9d7f62bf1e68962`.

**INCONCLUSIVE overall; NO_GO remains demonstrated for MUSA T02.** The two
paths have independent results:

| Path | Independent result | Reason |
|---|---|---|
| Official Julia 1.12.6 publication metadata | PASS | The official page links the exact archive, checksum list, detached signature, and release key; all bounded metadata identities match S3. |
| Archive-bound signature and installed Julia identity | INCONCLUSIVE | S3's declared retained root is absent, no executable Julia is available, and redownloading the 289,794,236-byte archive was prohibited. The archive bytes, signature binding, executable hash, and `julia version 1.12.6` output therefore could not be independently replayed. |
| Exact source-format condition | PASS statically; executed replay INCONCLUSIVE | The only two disallowed tabs are the exact predecessor lines reported by S3, and the worktree was not rewritten. This review's required `make fix-whitespace` also exited 2, but because `julia` was unavailable, not because the script reported those tabs. |
| MUSA 5.2.0 APT metadata | PASS through the detached route only | Inline `InRelease` verification fails, while `Release.gpg` validly signs `Release`, which binds `Packages.gz`. The index exposes component packages and metapackages only. |
| Complete vendor-authoritative MUSA 5.2.0 archive set | **NO_GO** | No vendor-linked complete `musa_toolkits_5.2.0.tar.gz`, archive checksum, detached archive/checksum signature chain, or release-bound authoritative complete per-file manifest was supplied or found. |

The missing Julia evidence prevents this independent review from promoting
S3's Julia PASS. It does not weaken or obscure the separately demonstrated
MUSA T02 failure. No 38-field replay was attempted because the atomic T02
input remains incomplete. No implementation, production, build, GPU,
runtime, compatibility, readiness, or formal-acceptance claim follows.

All commands were bounded, read-only, and CPU-only with the assigned ceiling
of two CPUs and `OMP_NUM_THREADS=2`. No large archive was downloaded; no
dependency was installed; and no credentials, service, database, driver,
device, GPU, artifact ingress, cleanup, deletion, move, rename, overwrite,
push, deployment, or formal decision action was used. Technical completion
is not formal acceptance.

## Accepted inputs and exact S3 scope

The accepted S2 subject and review were read in full. Their identities match
the S3 receipt:

```text
6ae8a3515fac538136d7bb50569a259f3e948ee7e8a09a8675a956416acd8c2a  doc/src/devdocs/musa-s2-metadata-gate-evidence.md
ea0e3effaf335a51aaf15498a9e5dbf882aafbd4072cba351e857fd05eb70dd0  doc/src/devdocs/reviews/musa-s2-full-metadata-gate-independent-review.md
```

The review began clean and detached at required S3 result
`2c2197f65b100f90b41da894b9d7f62bf1e68962`, tree
`1da7048cfe854f1c6ca07a4940b52fbab50e5831`. Its commit object has exactly
one parent, accepted S2 review result
`2f7dfae1415867c7b9ce688ef55818134b266d08`. The parent-to-S3 diff is exactly
one add-only mode-100644 path:

```text
A  doc/src/devdocs/musa-s3-authorized-dependency-acquisition.md
```

The S3 receipt's SHA-256 is
`cbad43803ed0cfcf6e650e0a2fc21234a40ddf1d67ee68a1df7cfbc5f1ea5378`.
There is no production, test, build-system, package, or existing-document
change in S3.

## Julia publication metadata and unavailable retained evidence

The official manual-download page identifies Julia 1.12.6 as the current
stable release dated April 9, 2026. Its HTML directly links:

```text
https://julialang-s3.julialang.org/bin/linux/x64/1.12/julia-1.12.6-linux-x86_64.tar.gz
https://julialang-s3.julialang.org/bin/linux/x64/1.12/julia-1.12.6-linux-x86_64.tar.gz.asc
https://julialang-s3.julialang.org/bin/checksums/julia-1.12.6.sha256
https://julialang.org/assets/juliareleases.asc
```

Bounded HTTPS probes fetched only the page, checksum list, signature, and key;
the archive received a HEAD request only. They independently reproduced:

```text
d44a6138f428b7a4cd4d4e6d0aba53bbf380d3279e575bfb743f668b7f88190f  julia-1.12.6.sha256
739c2a114eefa0004675232f9288f0061a91b1d6daba3730245903482d643cf1  julia-1.12.6-linux-x86_64.tar.gz.asc
a27705bf1e5a44d1905e669da0c990ac2d7ab7c13ec299e15bacdab5dcbb8d13  juliareleases.asc
```

The published archive line is:

```text
bbabf3bef19421a9dbd24a767d807606ab85e444323b5a1c73ffe293fa3d079a  julia-1.12.6-linux-x86_64.tar.gz
```

The archive HEAD probe exited 0 with HTTP 200, no redirect, content length
289,794,236, and last modification `Fri, 10 Apr 2026 16:15:04 GMT`.
`gpg --list-packets` over the detached signature exited 0 and named issuer
fingerprint `3673DF529D9049477F76B37566E3C7DC03D6E495`. `gpg --show-keys
--with-colons --fingerprint` over the key linked by the official page exited 0
with the same primary fingerprint and identity
`Julia (Binary signing key) <buildbot@julialang.org>`.

These probes authenticate the official source and metadata identities, but a
detached signature is not verified over content without the signed archive.
The root that S3 says retained all archive and installed bytes,
`/workspace/.gluon-c5f7b86f-s3-20260803T083206Z`, does not exist in this
review environment. Bounded executable searches found no
`/workspace/usr/bin/julia`, executable under `/workspace`, `/tmp`, `/opt`, or
`/usr/local`, or executable returned by `command -v julia`; the declared
Juliaup location was inaccessible and supplied no executable result. Thus
this review cannot independently authenticate S3's rejected overlapping
download, verified archive bytes, offline `GOODSIG`/`VALIDSIG`, installed
executable digest
`fd670aabc838e93f178cbcf7304c5e9c50aadcce3735e86d5e3218b1bb04e602`,
or installed version output. Those are S3 assertions, not independent results
in this receipt.

## Exact format-gate boundary

The immediate callers retain the S3 identities:

```text
8f8a6c499bc4fd4023f5db7a3a44ee6ca56957e09869cc2bc3272b2a4bff3d06  Makefile
312605c6fefeed042d0dc74b5d7d7f53c68d56bce86ce2c28e3054d3af0d743c  Make.inc
a6c913345e39138ebcdf71d5ea23e92917fe0bdf3d1397e81d62c439f4e915a9  contrib/check-whitespace.jl
```

An independent scan of every tracked whitespace-gate path, applying the
script's tab exemptions, exited 0 and returned exactly:

```text
doc/src/devdocs/reviews/musa-s1-metadata-inventory-correction-independent-review.md:52 -- tab
doc/src/devdocs/reviews/musa-s1-metadata-inventory-correction-independent-review.md:58 -- tab
```

Both tabs are embedded inside fenced predecessor evidence, not leading
indentation. Inspection of `contrib/check-whitespace.jl` confirms that its tab
fixer only rewrites matching leading indentation, so these two tabs are
reported but not rewritten. The required command was nevertheless executed:

```text
env OMP_NUM_THREADS=2 MAKEFLAGS=-j2 make fix-whitespace
/bin/sh: 1: julia: not found
make: *** [Makefile:185: fix-whitespace] Error 127
```

The outer exit was 2. Clean status before and after, an empty tracked diff,
and `git diff --check` exit 0 prove that this attempt made no tracked rewrite.
Because its inner failure differs from S3's reported whitespace-script exit
1, it does not independently replay S3's executed gate output even though the
exact underlying two-tab condition is independently established.

## MUSA publication and authority boundary

The vendor repository configuration package remains reachable at the exact
S3 URL. A bounded stream reproduced its SHA-256
`09577a0c1d613753e82e972e34c222a1c7bdcc0b444bb23ad71ae395e8ba61be`.
Without installation or persistent extraction, its keyring reported primary
fingerprint `5C804CAE420AFCC0BDD28FECEE9B8BE860C98FEF` and identity
`musatools <developers@mthreads.com>`.

The vendor metadata endpoints reproduced these identities:

```text
210a9491048eae7b208bf5bf62496a4b4988944f4a01356cff2204406d6777c3  InRelease
043a3d9bd8d6a35386ddc0821cf0f21998a3f95391ece656e2113ac65e9a2644  Release
1f11972ad8adb25721fb541e3e122131fdea16c05ba52b26b92dfb198151c36d  Release.gpg
f70967631c6376e3d4f429fc510db2ff31c787b11cd390c4804f35fc39bdcb8e  main/binary-amd64/Packages.gz
```

With streamed metadata held only in anonymous memory, `gpgv` against the
vendor keyring and `InRelease` exited 1 with `BAD signature`. This reproduces
the S3 inline-signature failure. S3 did not record the separately reachable
detached route: both `Release` and `Release.gpg` returned HTTP 200, and `gpgv`
over that pair with the same keyring exited 0 with `Good signature`. The
signed Release binds the exact observed `Packages.gz` SHA-256 and size 17,085.

Consequently the package index is authenticated by a valid vendor detached
route despite the bad inline signature. It lists 5.2.0 component packages and
the `musa-toolkit-5-2` and `musa-toolkit` metapackages. For example,
`musa-toolkit-5-2` is a 1,182-byte dependency-only metapackage with published
SHA-256
`f6a29a25f1d18c4595ba5bca6ffe942109acfa861b07ac1f236a54bbb7abb38d`.
This valid package authority is narrower than, and cannot substitute for, the
atomic offline archive authority required by accepted S2 T02.

The vendor installation guide was independently streamed with SHA-256
`5ea9c9e9a487a63244fb31de0252c228bd988ca5a9079e296a8e4889e7b23afd`.
It names `musa_toolkits_5.2.0.tar.gz` in an offline layout and extraction
example, but provides no link for it and no archive checksum, detached
archive/checksum signature chain, or authoritative complete per-file
manifest. Exact and prefix artifact-search API probes for
`musa_toolkits_5.2.0.tar.gz`, `musa_toolkits_5.2.0`, and `musa_toolkits` each
exited 0 with `{"results":[]}`; the exact response has SHA-256
`5021e624e752b001ce3e3846e8f158ed4aeb93a4c9a72fdb35a0c5b14a0eea84`.

The locally installed `/usr/local/musa` tree, its version identity, APT
component set, package filenames, and locally generated hashes are not the
missing archive authority. A package index—even a validly signed one—is not a
vendor release-bound manifest of every path, entry type, mode, link target,
size, and digest in the documented atomic archive. Therefore MUSA T02 remains
**NO_GO**, and no later row can bypass it.

## Command record and discrepancies

Commands ran from `/workspace`; all network commands used HTTPS, zero or
bounded redirects, `--fail`, and `--max-filesize` limits of 100,000 bytes for
repository metadata, 500,000 bytes for the MUSA guide, or 1,000,000 bytes for
the Julia page. The archive used `curl --head` only.

* `git status --porcelain=v1 --untracked-files=all`, `git rev-parse`,
  `git rev-list --parents -n 1`, `git diff-tree`, `git show`, and `sha256sum`
  authenticated the clean input, lineage, one-receipt scope, and identities;
  all exited 0.
* `curl ... | sha256sum`, `curl ... | gpg --list-packets`, and
  `curl ... | gpg --show-keys --with-colons --fingerprint` authenticated the
  bounded Julia metadata; each pipeline exited 0. No archive GET occurred.
* `find` and `command -v julia` found no usable retained Julia executable.
  The exact retained-root probe failed because the path is absent.
* The independent tracked tab scan exited 0 with exactly two records. The
  required make target exited 2 because its inner Julia lookup exited 127;
  status and diff checks remained clean.
* Streamed `dpkg-deb`, `tar`, `gzip`, `awk`, `rg`, and GPG inspection
  authenticated the repository configuration, key, package metadata, and
  names without installing or retaining packages. Inline `gpgv` exited 1;
  detached `gpgv` exited 0.
* The guide and three artifact-search probes exited 0. Searches found only
  the documented archive name and empty artifact-search results, not the
  complete authority set.

The two material S3 discrepancies are the absent declared Julia retention
root and the unreported valid detached APT Release route. The first prevents
independent Julia completion. The second upgrades only package-index
authentication and does not alter T02 or authorize a denominator replay.

## Smallest honest successor

The Julia path's smallest successor is an independent review environment in
which S3's exact retained, checksum-matching archive and installed tree are
made available read-only. It must verify the archive checksum, detached
signature against pinned fingerprint
`3673DF529D9049477F76B37566E3C7DC03D6E495`, installed executable digest and
`--version`, then execute `make fix-whitespace` and preserve its exact exit
and clean-diff evidence. It must not reacquire the large archive unless a new
task explicitly authorizes that ingress.

Independently, MUSA remains `SX/NO_GO` at T02 until an identified vendor owner
supplies one atomic set: the complete original MUSA Toolkit 5.2.0 archive for
an explicit supported host tuple, vendor-published checksum, detached
signature plus pinned verification chain, and a release/archive-bound
authoritative complete per-file manifest with acquisition provenance. Only
after every T02 input is independently complete may a successor replay all 38
applicable rows. Package metadata, installed files, names, and local hashes
remain prohibited substitutes. Technical evidence remains distinct from
formal acceptance.
