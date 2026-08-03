#!/bin/bash
set -euo pipefail

tooling=$(cd "$(dirname "$0")" && pwd)
sampler="$tooling/telemetry_sample.awk"
valid='17 4242 0 0 12 0 0 0 native_launcher'

sample=$(printf '%s\n' "$valid" | awk -v launcher_pid=4242 \
    -v device_name='MTT S5000' \
    -v proc_util_path=/proc/driver/musa/gpu-dynamic/proc_util -f "$sampler")
grep -q '^launcher_pid=4242$' <<< "$sample"
grep -q '^device_name=MTT S5000$' <<< "$sample"
grep -q '^activity_sum=12$' <<< "$sample"

if printf '%s\n' "$valid" | awk -v launcher_pid=4243 \
    -v device_name='MTT S5000' \
    -v proc_util_path=/proc/driver/musa/gpu-dynamic/proc_util -f "$sampler"; then
    echo "wrong-PID telemetry mutation was accepted" >&2
    exit 1
fi
if printf '%s\n' '17 4242 0 0 0 0 0 0 native_launcher' | \
    awk -v launcher_pid=4242 -v device_name='MTT S5000' \
    -v proc_util_path=/proc/driver/musa/gpu-dynamic/proc_util -f "$sampler"; then
    echo "zero-activity telemetry mutation was accepted" >&2
    exit 1
fi
if printf '%s\n' "$valid" | awk -v launcher_pid=4242 \
    -v device_name='Other GPU' \
    -v proc_util_path=/proc/driver/musa/gpu-dynamic/proc_util -f "$sampler"; then
    echo "non-S5000 telemetry mutation was accepted" >&2
    exit 1
fi
if printf '%s\n' "$valid" | awk -v launcher_pid=4242 \
    -v device_name='MTT S5000' -v proc_util_path=/tmp/proc_util -f "$sampler"; then
    echo "non-driver telemetry path mutation was accepted" >&2
    exit 1
fi

echo "PASS: exact-PID, nonzero-activity, dynamic-path, and S5000 telemetry guards"
