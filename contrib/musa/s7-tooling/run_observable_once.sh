#!/bin/bash
set -euo pipefail
set -o noclobber

root=$(cd "$(dirname "$0")/../../.." && pwd)
tooling="$root/contrib/musa/s7-tooling"
object="$root/contrib/musa/s6-tooling/evidence/julia-scalar-mp31.o"
evidence="$tooling/evidence-s7r1"
sampler="$tooling/telemetry_sample.awk"
expected_hash=900f21e154fe092b572d30236fee343b3b1898d888a13144ab6537a01b645965
timeout_seconds=600

if [[ -e "$evidence" ]]; then
    echo "refusing to replay or overwrite S7R1 evidence: $evidence" >&2
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
sha256sum "$tooling/native_launcher" > "$evidence/executed-launcher.sha256"
readelf -d "$tooling/native_launcher" > "$evidence/launcher-dynamic-section.log"
ldd "$tooling/native_launcher" > "$evidence/launcher-ldd.log"
mapfile -t needed < <(sed -n 's/.*Shared library: \[\([^]]*\)\].*/\1/p' \
    "$evidence/launcher-dynamic-section.log")
if [[ "${#needed[@]}" -ne 2 ]] ||
   [[ " ${needed[*]} " != *" libmusa.so.1 "* ]] ||
   [[ " ${needed[*]} " != *" libc.so.6 "* ]]; then
    echo "launcher dependency gate failed: ${needed[*]}" >&2
    exit 72
fi

set +e
OMP_NUM_THREADS=2 timeout --foreground --signal=KILL "$timeout_seconds" \
    "$tooling/native_launcher" "$object" \
    > "$evidence/launcher.stdout.log" 2> "$evidence/launcher.stderr.log" &
timeout_pid=$!

launcher_pid=
while kill -0 "$timeout_pid" 2>/dev/null; do
    launcher_pid=$(sed -n 's/^launcher_pid=\([1-9][0-9]*\)$/\1/p' \
        "$evidence/launcher.stdout.log")
    [[ -n "$launcher_pid" ]] && break
done

activity_found=0
identity_ok=0
if [[ -n "$launcher_pid" && -r "/proc/$launcher_pid/comm" ]]; then
    launcher_comm=$(<"/proc/$launcher_pid/comm")
    launcher_exe=$(readlink "/proc/$launcher_pid/exe")
    if [[ "$launcher_comm" == native_launcher && "$launcher_exe" == "$tooling/native_launcher" ]]; then
        identity_ok=1
        {
            echo "launcher_pid=$launcher_pid"
            echo "launcher_comm=$launcher_comm"
            echo "launcher_exe=$launcher_exe"
        } > "$evidence/launcher-pid-identity.log"
    fi
fi

if [[ "$identity_ok" -eq 1 ]]; then
    while kill -0 "$launcher_pid" 2>/dev/null; do
        for proc_util in /proc/driver/musa/gpu*/proc_util; do
            [[ -r "$proc_util" ]] || continue
            device_dir=${proc_util%/proc_util}
            [[ -r "$device_dir/devname" ]] || continue
            device_name=$(<"$device_dir/devname")
            if activity_line=$(awk -v launcher_pid="$launcher_pid" \
                -v device_name="$device_name" -v proc_util_path="$proc_util" \
                -f "$sampler" "$proc_util"); then
                printf '%s\n' "$activity_line" \
                    > "$evidence/nonzero-assigned-device-activity.log"
                activity_found=1
                break 2
            fi
        done
    done
fi

wait "$timeout_pid"
launcher_exit=$?
set -e

result=INCONCLUSIVE
if [[ "$launcher_exit" -ne 0 ]]; then
    result=NO_GO
elif [[ "$identity_ok" -eq 1 && "$activity_found" -eq 1 ]] &&
     grep -q '^KERNEL_OK: observed=0x10000008 expected=0x10000008 exact=true$' \
        "$evidence/launcher.stdout.log"; then
    result=GO
fi

{
    echo "result=$result"
    echo "launcher_exit=$launcher_exit"
    echo "pid_identity=$identity_ok"
    echo "nonzero_activity=$activity_found"
    echo "workload_invocations=1"
    echo "repeat_count=256"
    echo "timeout_seconds=$timeout_seconds"
} > "$evidence/result.log"

cat "$evidence/result.log"
cat "$evidence/launcher.stdout.log"
cat "$evidence/launcher.stderr.log" >&2
[[ "$result" == GO ]]
