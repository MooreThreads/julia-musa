#!/bin/bash
set -euo pipefail

tooling=$(cd "$(dirname "$0")" && pwd)
sampler="$tooling/telemetry_sample.awk"
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
