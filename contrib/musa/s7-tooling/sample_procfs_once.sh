#!/bin/bash
set -euo pipefail

if [[ "$#" -ne 1 || ! "$1" =~ ^[1-9][0-9]*$ ]]; then
    echo "usage: $0 LAUNCHER_PID" >&2
    exit 64
fi

tooling=$(cd "$(dirname "$0")" && pwd)
sampler="$tooling/telemetry_sample.awk"
launcher_pid=$1
shopt -s nullglob
proc_util_sources=(/proc/driver/musa/gpu*/proc_util)

{
    for proc_util in "${proc_util_sources[@]}"; do
        [[ -r "$proc_util" ]] || continue
        device_dir=${proc_util%/proc_util}
        [[ -r "$device_dir/devname" ]] || continue
        node_label=$(<"$device_dir/devname")
        printf '@source %s %s\n' "$proc_util" "$node_label"
        sed -n '2,$p' "$proc_util"
    done
} | awk -v launcher_pid="$launcher_pid" -f "$sampler"
