#!/bin/bash
set -euo pipefail
set -o noclobber

root=$(cd "$(dirname "$0")/../../.." && pwd)
tooling="$root/contrib/musa/s7-tooling"
object="$root/contrib/musa/s6-tooling/evidence/julia-scalar-mp31.o"
evidence="$tooling/evidence"
expected_hash=900f21e154fe092b572d30236fee343b3b1898d888a13144ab6537a01b645965

if [[ -e "$evidence" ]]; then
    echo "refusing to replay or overwrite S7 evidence: $evidence" >&2
    exit 70
fi

actual_hash=$(sha256sum "$object" | awk '{print $1}')
if [[ "$actual_hash" != "$expected_hash" ]]; then
    echo "retained object hash mismatch: expected=$expected_hash actual=$actual_hash" >&2
    exit 71
fi

make -C "$tooling" test
mkdir "$evidence"
"$tooling/native_launcher" --print-contract > "$evidence/frozen-contract.log"
sha256sum "$object" > "$evidence/retained-object.sha256"
readelf -d "$tooling/native_launcher" > "$evidence/launcher-dynamic-section.log"
ldd "$tooling/native_launcher" > "$evidence/launcher-ldd.log"

set +e
OMP_NUM_THREADS=2 timeout --foreground --signal=KILL 600 \
    "$tooling/native_launcher" "$object" \
    > "$evidence/launcher.stdout.log" 2> "$evidence/launcher.stderr.log" &
timeout_pid=$!

activity_found=0
while kill -0 "$timeout_pid" 2>/dev/null; do
    for proc_util in /proc/driver/musa/gpu*/proc_util; do
        [[ -r "$proc_util" ]] || continue
        activity_line=$(awk '
            ($9 == "native_launcher") && (($3 + $4 + $5 + $6 + $7 + $8) > 0) {
                print FILENAME ":" $0
            }
        ' "$proc_util")
        if [[ -n "$activity_line" ]]; then
            printf '%s\n' "$activity_line" > "$evidence/nonzero-assigned-device-activity.log"
            activity_found=1
            break 2
        fi
    done
done
wait "$timeout_pid"
launcher_exit=$?
set -e

if [[ "$activity_found" -ne 1 ]]; then
    printf '%s\n' "no nonzero process utilization observed concurrently" \
        > "$evidence/no-observed-activity.log"
fi

result=INCONCLUSIVE
if [[ "$launcher_exit" -ne 0 ]]; then
    result=NO_GO
elif [[ "$activity_found" -eq 1 ]] &&
     grep -q '^KERNEL_OK: observed=0x10000008 expected=0x10000008 exact=true$' \
        "$evidence/launcher.stdout.log"; then
    result=GO
fi

{
    echo "result=$result"
    echo "launcher_exit=$launcher_exit"
    echo "nonzero_activity=$activity_found"
    echo "run_count=1"
    echo "timeout_seconds=600"
} > "$evidence/result.log"

cat "$evidence/result.log"
cat "$evidence/launcher.stdout.log"
cat "$evidence/launcher.stderr.log" >&2
[[ "$result" == GO ]]
