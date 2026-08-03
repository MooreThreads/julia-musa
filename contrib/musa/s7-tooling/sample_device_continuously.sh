#!/bin/bash
set -euo pipefail
set -o noclobber

if [[ "$#" -ne 8 || ! "$1" =~ ^mtgpu\.[0-9]+$ || ! "$2" =~ ^/proc/driver/musa/gpu[0-9]+$ ]]; then
    echo "usage: $0 DEVICE_LABEL PROC_DEVICE_DIR RAW_LOG PID_FILE READY_FILE ARMED_FILE DONE_FILE EXPECTED_EXE" >&2
    exit 64
fi

device_label=$1
device_dir=$2
raw_log=$3
pid_file=$4
ready_file=$5
armed_file=$6
done_file=$7
expected_exe=$8
poll_interval=0.005
max_samples=120000
sample_count=0
identity_seen=0

if [[ ! -r "$device_dir/devname" || "$(<"$device_dir/devname")" != "$device_label" ]]; then
    echo "assigned-device procfs mapping is unavailable: $device_label -> $device_dir" >&2
    exit 65
fi

sources=(proc_util status int_status memory)
for source in "${sources[@]}"; do
    if [[ ! -r "$device_dir/$source" ]]; then
        echo "assigned-device telemetry source is unreadable: $device_dir/$source" >&2
        exit 66
    fi
done

collect_sample()
{
    local source timestamp_ns
    timestamp_ns=$(date +%s%N)
    printf '@sample timestamp_ns=%s device=%s\n' "$timestamp_ns" "$device_label"
    for source in "${sources[@]}"; do
        printf '@source path=%s/%s\n' "$device_dir" "$source"
        sed -n '1,200p' "$device_dir/$source"
        printf '@end_source\n'
    done
    printf '@end_sample\n'
    sample_count=$((sample_count + 1))
}

exec 3> "$raw_log"
start_ns=$(date +%s%N)
printf '@sampler_start timestamp_ns=%s device=%s poll_interval_seconds=%s max_samples=%d\n' \
    "$start_ns" "$device_label" "$poll_interval" "$max_samples" >&3
collect_sample >&3
printf 'ready\n' > "$ready_file"

while [[ ! -e "$done_file" ]]; do
    if [[ "$identity_seen" -eq 0 && -r "$pid_file" ]]; then
        launcher_pid=$(<"$pid_file")
        if [[ ! "$launcher_pid" =~ ^[1-9][0-9]*$ || ! -r "/proc/$launcher_pid/comm" ]]; then
            echo "launcher PID identity is unavailable: $launcher_pid" >&2
            exit 67
        fi
        launcher_comm=$(<"/proc/$launcher_pid/comm")
        launcher_exe=$(readlink "/proc/$launcher_pid/exe")
        if [[ "$launcher_comm" != native_launcher || "$launcher_exe" != "$expected_exe" ]]; then
            echo "launcher PID identity mismatch: pid=$launcher_pid comm=$launcher_comm exe=$launcher_exe" >&2
            exit 68
        fi
        printf '@launcher_identity pid=%s comm=%s exe=%s\n' \
            "$launcher_pid" "$launcher_comm" "$launcher_exe" >&3
        collect_sample >&3
        printf 'armed\n' > "$armed_file"
        identity_seen=1
    fi
    collect_sample >&3
    if [[ "$sample_count" -ge "$max_samples" ]]; then
        echo "continuous sampler reached its bounded sample limit" >&2
        exit 69
    fi
    sleep "$poll_interval"
done

collect_sample >&3
end_ns=$(date +%s%N)
printf '@sampler_end timestamp_ns=%s samples=%d identity_seen=%d\n' \
    "$end_ns" "$sample_count" "$identity_seen" >&3
[[ "$identity_seen" -eq 1 ]]
