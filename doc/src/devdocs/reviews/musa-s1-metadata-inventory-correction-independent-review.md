# Independent review of the MUSA S1 metadata inventory correction

## Scope and advisory verdict

**Advisory GO for metadata accuracy only.** No critical, high, medium, or low
finding was identified in corrected subject
`df891bdc2a9675e872c94c3bab86c6bff6afe5a9`. This review does not formally
accept the correction, authorize S2, or claim Julia, LLVM.jl, GPUCompiler.jl,
or MUSA implementation, support, interoperability, or compatibility. Technical
success is not formal acceptance.

The review was performed without network or remote access, fetches,
installation, package managers, compilers, linkers, vendor executables, Julia,
GPU or device access, credentials, services, databases, formal-review actions,
pushes, or deployment. Evidence was limited to the checked-out Git objects and
static installed files under `/usr/local/musa`.

## Severity-ranked findings

### Critical

None.

### High

None.

### Medium

None.

### Low

None.

## Exact subject identity and lineage

At review start, `git rev-parse HEAD` returned exactly
`df891bdc2a9675e872c94c3bab86c6bff6afe5a9`, and `git status --short --branch`
reported detached `HEAD` with no changes. `git rev-list --parents -n 1` returned
exactly:

```text
df891bdc2a9675e872c94c3bab86c6bff6afe5a9 a380e087cf97e6b658c6d30129290c08fc42b787
```

Thus the corrected subject is a direct child of the accepted base and has
exactly one parent. `git diff-tree --no-commit-id --name-status -r` reported
only:

```text
A	doc/src/devdocs/musa-s1-metadata-inventory.md
```

The raw diff-tree record was:

```text
:000000 100644 0000000000000000000000000000000000000000 a666327f1ba501901a90688deb753bb328ff6af7 A	doc/src/devdocs/musa-s1-metadata-inventory.md
```

The path cannot be resolved in the accepted parent (`git show` exited 128), so
this is an add-only mode-100644 change, not a replacement. `git diff --check
a380e087cf97e6b658c6d30129290c08fc42b787
df891bdc2a9675e872c94c3bab86c6bff6afe5a9` produced no output.

## Independent device-library replay

`sha256sum` was run directly on the three authorized installed static files.
It returned:

```text
e22ae18cbb72b442096bbac4341486a860df368b480a7461b2907dc2c28242ff  /usr/local/musa/mtgpu/bitcode/libdevice.bc
02ac83ee89177aac80e93281e18ef30a3b344c578e567584739e3ebb2a169bde  /usr/local/musa/mtgpu/bitcode/libdevice.mthg.bc
9e51f7724e93bce7d7f3c0b43752d53ee7b37b0a7ec3aa01399358e279cdb766  /usr/local/musa/mtgpu/bitcode/libdevice.31.bc
```

Each value exactly matches the corrected inventory. Static `stat` inspection
identified all three inputs as regular mode-0644 files, with sizes 882072,
882312, and 887964 bytes in the order shown. A direct character count of the
`libdevice.31.bc` digest returned exactly 64. This replay closes the independent
check of the repaired T08 identity; it does not change the committed
inventory's conservative T08 failure or establish device-library selection or
ABI compatibility.

## Denominator and S2 predicate replay

The S1 table was parsed by its 40 field rows and final outcome column. The
independent recomputation returned:

```text
fields=40 P=8 F=30 S=0 I=0 N=2 applicable=38
P_ids=T01,T05,T06,T07,A01,A02,A09,O01
F_ids=T02,T03,T04,T08,T09,T10,A03,A04,A05,A06,A07,A08,A10,A11,A12,A13,A14,A15,P01,P02,P03,P04,P05,P06,P07,P08,L01,L02,L03,L04
N_ids=O02,O03
```

There are no hidden skips or inconclusive rows. T08 is explicitly included in
the 30 failures. Excluding only O02 and O03 as `NOT_APPLICABLE` leaves exactly
38 applicable fields.

The committed S2 predicate requires all 38 applicable fields to be `VERIFIED`
at the committed repaired result. It explicitly requires replay of every
current pass—T01, T05 through T07, A01, A02, A09, and O01—as well as corrected
T08 and closure of every other current failure. It also states that no
applicable field may be skipped or inconclusive and repeats that all 38, rather
than only the currently failed fields, must be reverified. The gate therefore
does not carry current passes forward without evidence.

## Boundary conclusion

The subject consistently labels itself a metadata and ownership inventory,
keeps S2 and later slices at `NO_GO`, and disclaims Julia/MUSA support and
compatibility. Its device-library statements are static file identities, not
execution or selection proof. The corrected report therefore remains
metadata-only, and this advisory GO is bounded to the accuracy of the repaired
identity, denominator, and gate wording reviewed above.
