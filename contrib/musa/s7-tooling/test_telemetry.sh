#!/bin/bash
set -euo pipefail

tooling=$(cd "$(dirname "$0")" && pwd)
sampler="$tooling/telemetry_sample.awk"
continuous_evaluator="$tooling/evaluate_continuous_telemetry.awk"
header='Pid VPid Total 2D TA 3D CMP TRANSFER PidName'
valid='17 4242 0 0 12 0 0 0 native_launcher'
source='@source /proc/driver/musa/gpu00/proc_util mtgpu.0'

sample=$(printf '%s\n' "$source" "$header" "$valid" | \
    awk -v launcher_pid=4242 -f "$sampler")
grep -q '^launcher_pid=4242$' <<< "$sample"
grep -q '^node_label=mtgpu.0$' <<< "$sample"
grep -q '^proc_util_path=/proc/driver/musa/gpu00/proc_util$' <<< "$sample"
grep -q '^activity_sum=12$' <<< "$sample"

if printf '%s\n' "$source" "$header" "$valid" | \
    awk -v launcher_pid=4243 -f "$sampler"; then
    echo "wrong-PID telemetry mutation was accepted" >&2
    exit 1
fi
if printf '%s\n' "$source" "$header" \
    '17 4242 0 0 0 0 0 0 native_launcher' | \
    awk -v launcher_pid=4242 -f "$sampler"; then
    echo "zero-activity telemetry mutation was accepted" >&2
    exit 1
fi
if printf '%s\n' '@source /proc/driver/musa/gpu00/proc_util S5000' \
    "$header" "$valid" | awk -v launcher_pid=4242 -f "$sampler"; then
    echo "non-mtgpu node-label mutation was accepted" >&2
    exit 1
fi
if printf '%s\n' "$source" \
    'Pid VPid Memory 2D TA 3D CMP TRANSFER PidName' "$valid" | \
    awk -v launcher_pid=4242 -f "$sampler"; then
    echo "wrong proc-util columns were accepted" >&2
    exit 1
fi
duplicate_source='@source /proc/driver/musa/gpu01/proc_util mtgpu.1'
if printf '%s\n' "$source" "$header" "$valid" "$duplicate_source" \
    "$header" '4242 88 1 0 0 0 0 0 native_launcher' | \
    awk -v launcher_pid=4242 -f "$sampler"; then
    echo "non-unique exact-PID telemetry mutation was accepted" >&2
    exit 1
fi

echo "PASS: real columns, mtgpu labels, exact-PID uniqueness, and nonzero activity"

# The continuous evaluator must retain only assigned-device activity from the access window.
continuous_sample()
{
    local timestamp=$1 device=$2 pid=$3 activity=$4 interrupts=$5 status=$6
    printf '@sample timestamp_ns=%s device=%s\n' "$timestamp" "$device"
    printf '@source path=/proc/driver/musa/gpu00/proc_util\n'
    printf '%s\n' 'device: (0, 128)' "$header"
    if [[ "$pid" != none ]]; then
        printf '17 %s 0 0 0 0 %s 0 native_launcher\n' "$pid" "$activity"
    fi
    printf '%s\n' '@end_source'
    printf '%s\n' '@source path=/proc/driver/musa/gpu00/status'
    printf 'GPU Overall Utilisation: %s%%\n' "$status"
    printf '%s\n' '@end_source'
    printf '%s\n' '@source path=/proc/driver/musa/gpu00/int_status'
    printf 'target 0 host_irq: 1 received_int_times: %s completed_int_times: %s last_claim_int_id: 1\n' \
        "$interrupts" "$interrupts"
    printf '%s\n' '@end_source'
    printf '%s\n' '@source path=/proc/driver/musa/gpu00/memory' 'MemoryUsageAllocGPUMemLMA 0'
    printf '%s\n' '@end_source' '@end_sample'
}

continuous_log()
{
    local in_pid=$1 in_activity=$2 in_interrupts=$3 in_status=$4 in_timestamp=${5:-220}
    printf '%s\n' \
        '@sampler_start timestamp_ns=100 device=mtgpu.0 poll_interval_seconds=0.005 max_samples=120000' \
        '@launcher_identity pid=4242 comm=native_launcher exe=/workspace/contrib/musa/s7-tooling/native_launcher'
    continuous_sample 150 mtgpu.0 none 0 10 0
    continuous_sample "$in_timestamp" mtgpu.0 "$in_pid" "$in_activity" "$in_interrupts" "$in_status"
    printf '%s\n' '@sampler_end timestamp_ns=350 samples=2 identity_seen=1'
}

evaluate_continuous()
{
    awk -v launcher_pid=4242 -v assigned_device=mtgpu.0 \
        -v assigned_dir=/proc/driver/musa/gpu00 \
        -v access_start_ns=200 -v access_end_ns=300 \
        -f "$continuous_evaluator"
}

continuous_result=$(continuous_log 4242 12 10 0 | evaluate_continuous)
grep -q '^activity_kind=exact_pid$' <<< "$continuous_result"

global_result=$(continuous_log none 0 11 0 | evaluate_continuous)
grep -q '^activity_kind=interrupt_counter_delta$' <<< "$global_result"

if continuous_log 4243 12 10 0 | evaluate_continuous >/dev/null; then
    echo "wrong-PID continuous evidence was accepted" >&2
    exit 1
fi
if continuous_log 4242 12 10 0 | sed 's/device=mtgpu\.0/device=mtgpu.1/g' | \
    evaluate_continuous >/dev/null; then
    echo "wrong-device continuous evidence was accepted" >&2
    exit 1
fi
if continuous_log 4242 0 10 0 | evaluate_continuous >/dev/null; then
    echo "all-zero continuous evidence was accepted" >&2
    exit 1
fi
if continuous_log 4242 12 10 0 150 | evaluate_continuous >/dev/null; then
    echo "out-of-window continuous evidence was accepted" >&2
    exit 1
fi

echo "PASS: continuous assigned-device window rejects wrong device/PID, zero, and out-of-window evidence"
