#!/bin/bash
set -euo pipefail
set -o noclobber

root=$(cd "$(dirname "$0")/../../.." && pwd)
tooling="$root/contrib/musa/s7-tooling"
object="$root/contrib/musa/s6-tooling/evidence/julia-scalar-mp31.o"
receipt=${S7_RECEIPT:-s7r3}
if [[ "$receipt" != s7r3 && "$receipt" != s7r4 ]]; then
    echo "unsupported continuous receipt: $receipt" >&2
    exit 64
fi
evidence="$tooling/evidence-$receipt"
sampler="$tooling/sample_device_continuously.sh"
evaluator="$tooling/evaluate_continuous_telemetry.awk"
expected_hash=900f21e154fe092b572d30236fee343b3b1898d888a13144ab6537a01b645965
expected_base=efe0520915505efce02626ed3ad20dc8e714d4d2
timeout_seconds=600

if [[ -e "$evidence" ]]; then
    echo "refusing to replay or overwrite $receipt evidence: $evidence" >&2
    exit 70
fi
actual_base=$(git -C "$root" rev-parse HEAD)
if [[ "$actual_base" != "$expected_base" ]]; then
    echo "base commit mismatch: expected=$expected_base actual=$actual_base" >&2
    exit 70
fi
actual_hash=$(sha256sum "$object" | awk '{print $1}')
if [[ "$actual_hash" != "$expected_hash" ]]; then
    echo "retained object hash mismatch: expected=$expected_hash actual=$actual_hash" >&2
    exit 71
fi

shopt -s nullglob
device_nodes=(/dev/mtgpu.*)
visible_nodes=()
for node in "${device_nodes[@]}"; do
    [[ -c "$node" ]] && visible_nodes+=("$node")
done
if [[ "${#visible_nodes[@]}" -ne 1 ]]; then
    echo "expected one dynamically exposed MTGPU character device, found ${#visible_nodes[@]}" >&2
    exit 72
fi
assigned_device=${visible_nodes[0]##*/}
assigned_dirs=()
for device_dir in /proc/driver/musa/gpu*; do
    [[ -r "$device_dir/devname" ]] || continue
    [[ "$(<"$device_dir/devname")" == "$assigned_device" ]] && assigned_dirs+=("$device_dir")
done
if [[ "${#assigned_dirs[@]}" -ne 1 ]]; then
    echo "expected one procfs mapping for $assigned_device, found ${#assigned_dirs[@]}" >&2
    exit 73
fi
assigned_dir=${assigned_dirs[0]}

mkdir "$evidence"
printf '%s\n' \
    'continuous-telemetry.raw.log whitespace=-trailing-space' \
    'frozen-telemetry-interface.log whitespace=-trailing-space' \
    > "$evidence/.gitattributes"
make -C "$tooling" test > "$evidence/pre-device-tests.log" 2>&1
"$tooling/native_launcher" --print-contract > "$evidence/frozen-contract.log"
sha256sum "$object" > "$evidence/retained-object.sha256"
sha256sum "$tooling/native_launcher" > "$evidence/executed-launcher.sha256"
sha256sum "$0" "$tooling/native_launcher.c" "$tooling/native_launcher.h" \
    "$tooling/test_native_launcher.c" "$sampler" "$evaluator" \
    "$tooling/test_telemetry.sh" \
    > "$evidence/frozen-sampler.sha256"
{
    echo "base_commit=$expected_base"
    echo "pre_device_tests=make -C $tooling test"
    echo "object_check=sha256sum $object"
    echo "sampler=$sampler DYNAMIC_DEVICE_LABEL DYNAMIC_PROCFS_DIR RAW_LOG PID_FILE READY_FILE ARMED_FILE DONE_FILE $tooling/native_launcher"
    echo "launcher=OMP_NUM_THREADS=2 timeout --foreground --signal=KILL $timeout_seconds $tooling/native_launcher --start-gate START_GATE $object"
    echo "evaluator=awk -v launcher_pid=DYNAMIC_PID -v assigned_device=DYNAMIC_DEVICE_LABEL -v assigned_dir=DYNAMIC_PROCFS_DIR -v access_start_ns=LAUNCHER_START -v access_end_ns=LAUNCHER_END -f $evaluator RAW_LOG"
} > "$evidence/frozen-commands.log"
{
    echo "assigned_device_node=${visible_nodes[0]}"
    echo "assigned_device_label=$assigned_device"
    echo "assigned_procfs_dir=$assigned_dir"
    for source in devname proc_util status int_status memory; do
        echo "@source $assigned_dir/$source"
        sed -n '1,200p' "$assigned_dir/$source"
    done
} > "$evidence/frozen-telemetry-interface.log"
readelf -d "$tooling/native_launcher" > "$evidence/launcher-dynamic-section.log"
ldd "$tooling/native_launcher" > "$evidence/launcher-ldd.log"
mapfile -t needed < <(sed -n 's/.*Shared library: \[\([^]]*\)\].*/\1/p' \
    "$evidence/launcher-dynamic-section.log")
if [[ "${#needed[@]}" -ne 2 ]] ||
   [[ " ${needed[*]} " != *" libmusa.so.1 "* ]] ||
   [[ " ${needed[*]} " != *" libc.so.6 "* ]]; then
    echo "launcher dependency gate failed: ${needed[*]}" >&2
    exit 74
fi

pid_file="$evidence/launcher.pid"
ready_file="$evidence/sampler.ready"
armed_file="$evidence/sampler.armed"
done_file="$evidence/launcher.done"
gate_file="$evidence/start.gate"
raw_log="$evidence/continuous-telemetry.raw.log"

"$sampler" "$assigned_device" "$assigned_dir" "$raw_log" "$pid_file" \
    "$ready_file" "$armed_file" "$done_file" "$tooling/native_launcher" \
    > "$evidence/sampler.stdout.log" 2> "$evidence/sampler.stderr.log" &
sampler_pid=$!
for ((attempt = 0; attempt < 60000; attempt++)); do
    [[ -r "$ready_file" ]] && break
    kill -0 "$sampler_pid" 2>/dev/null || break
    sleep 0.001
done
if [[ ! -r "$ready_file" ]]; then
    wait "$sampler_pid" || true
    echo "continuous sampler did not become ready" >&2
    exit 75
fi

set +e
OMP_NUM_THREADS=2 timeout --foreground --signal=KILL "$timeout_seconds" \
    "$tooling/native_launcher" --start-gate "$gate_file" "$object" \
    > "$evidence/launcher.stdout.log" 2> "$evidence/launcher.stderr.log" &
timeout_pid=$!

launcher_pid=
for ((attempt = 0; attempt < 60000; attempt++)); do
    launcher_pid=$(sed -n 's/^launcher_pid=\([1-9][0-9]*\)$/\1/p' \
        "$evidence/launcher.stdout.log")
    [[ -n "$launcher_pid" ]] && break
    kill -0 "$timeout_pid" 2>/dev/null || break
    sleep 0.001
done
if [[ -n "$launcher_pid" ]]; then
    printf '%s\n' "$launcher_pid" > "$pid_file"
fi

for ((attempt = 0; attempt < 60000; attempt++)); do
    [[ -r "$armed_file" ]] && break
    kill -0 "$sampler_pid" 2>/dev/null || break
    kill -0 "$timeout_pid" 2>/dev/null || break
    sleep 0.001
done
if [[ -r "$armed_file" ]]; then
    printf 'armed\n' > "$gate_file"
else
    printf 'invalid\n' > "$gate_file"
fi

wait "$timeout_pid"
launcher_exit=$?
printf 'done\n' > "$done_file"
wait "$sampler_pid"
sampler_exit=$?
set -e

{
    echo "accepted_token=armed\\n"
    echo "accepted_token_bytes=$(wc -c < "$gate_file")"
    echo "accepted_token_sha256=$(sha256sum "$gate_file" | awk '{print $1}')"
    echo "complete_token_retry=1"
} > "$evidence/gate-contract.log"

access_start_ns=$(sed -n 's/^device_access_start_ns=\([1-9][0-9]*\)$/\1/p' \
    "$evidence/launcher.stdout.log")
access_end_ns=$(sed -n 's/^device_access_end_ns=\([1-9][0-9]*\)$/\1/p' \
    "$evidence/launcher.stdout.log")
activity_found=0
evaluator_exit=1
if [[ -n "$launcher_pid" && -n "$access_start_ns" && -n "$access_end_ns" ]]; then
    set +e
    awk -v launcher_pid="$launcher_pid" -v assigned_device="$assigned_device" \
        -v assigned_dir="$assigned_dir" -v access_start_ns="$access_start_ns" \
        -v access_end_ns="$access_end_ns" -f "$evaluator" "$raw_log" \
        > "$evidence/nonzero-assigned-device-activity.log"
    evaluator_exit=$?
    set -e
    [[ "$evaluator_exit" -eq 0 ]] && activity_found=1
fi

identity_ok=0
if grep -q "^@launcher_identity pid=$launcher_pid comm=native_launcher exe=$tooling/native_launcher$" \
    "$raw_log"; then
    identity_ok=1
    grep '^@launcher_identity ' "$raw_log" > "$evidence/launcher-pid-identity.log"
fi

result=INCONCLUSIVE
if [[ "$launcher_exit" -ne 0 || "$sampler_exit" -ne 0 || "$evaluator_exit" -eq 2 ]]; then
    result=NO_GO
elif [[ "$identity_ok" -eq 1 && "$activity_found" -eq 1 ]] &&
     grep -q '^driver_device_name=.*S5000' "$evidence/launcher.stdout.log" &&
     grep -q '^KERNEL_OK: observed=0x10000008 expected=0x10000008 exact=true$' \
        "$evidence/launcher.stdout.log"; then
    result=GO
fi

{
    echo "result=$result"
    echo "launcher_exit=$launcher_exit"
    echo "sampler_exit=$sampler_exit"
    echo "evaluator_exit=$evaluator_exit"
    echo "pid_identity=$identity_ok"
    echo "nonzero_activity=$activity_found"
    echo "assigned_device=$assigned_device"
    echo "workload_invocations=1"
    echo "repeat_count=4096"
    echo "timeout_seconds=$timeout_seconds"
} > "$evidence/result.log"

cat "$evidence/result.log"
cat "$evidence/launcher.stdout.log"
cat "$evidence/launcher.stderr.log" >&2
cat "$evidence/sampler.stderr.log" >&2
[[ "$result" == GO ]]
