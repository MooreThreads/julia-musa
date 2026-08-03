function invalid_contract() {
    invalid = 1
    exit 2
}

function field_value(position, pair, count) {
    count = split($position, pair, "=")
    if (count != 2)
        invalid_contract()
    return pair[2]
}

function numeric(value) {
    return value ~ /^([0-9]+([.][0-9]*)?|[.][0-9]+)$/
}

function finish_sample(    delta) {
    if (!in_sample)
        invalid_contract()
    if (sample_device != assigned_device)
        invalid_contract()
    if (!proc_seen || !status_seen || !interrupt_seen || !memory_seen)
        invalid_contract()

    if (sample_timestamp < access_start_ns) {
        baseline_seen = 1
        baseline_interrupt = interrupt_total
        baseline_status = status_activity
    }
    else if (sample_timestamp <= access_end_ns) {
        in_window_samples++
        if (pid_activity > 0 && !pid_match) {
            pid_match = 1
            pid_match_timestamp = sample_timestamp
            pid_match_path = proc_path
            pid_match_row = active_row
            pid_match_sum = pid_activity
        }
        if (baseline_seen) {
            delta = interrupt_total - baseline_interrupt
            if (delta > global_delta) {
                global_delta = delta
                global_timestamp = sample_timestamp
                global_path = interrupt_path
                global_kind = "interrupt_counter_delta"
            }
            delta = status_activity - baseline_status
            if (delta > global_delta) {
                global_delta = delta
                global_timestamp = sample_timestamp
                global_path = status_path
                global_kind = "utilisation_delta"
            }
        }
    }
    in_sample = 0
}

BEGIN {
    if (launcher_pid !~ /^[1-9][0-9]*$/ ||
        assigned_device !~ /^mtgpu\.[0-9]+$/ ||
        assigned_dir !~ /^\/proc\/driver\/musa\/gpu[0-9]+$/ ||
        access_start_ns !~ /^[1-9][0-9]*$/ ||
        access_end_ns !~ /^[1-9][0-9]*$/ ||
        access_start_ns >= access_end_ns)
        invalid_contract()
}

$1 == "@sampler_start" {
    if (sampler_start_seen || NF != 5 || field_value(3) != assigned_device)
        invalid_contract()
    sampler_start = field_value(2)
    sampler_start_seen = 1
    next
}

$1 == "@launcher_identity" {
    if (NF != 4 || field_value(2) != launcher_pid ||
        field_value(3) != "native_launcher")
        invalid_contract()
    identity_seen = 1
    next
}

$1 == "@sample" {
    if (in_sample || NF != 3)
        invalid_contract()
    sample_timestamp = field_value(2)
    sample_device = field_value(3)
    if (sample_timestamp !~ /^[1-9][0-9]*$/)
        invalid_contract()
    in_sample = 1
    source_path = ""
    proc_seen = status_seen = interrupt_seen = memory_seen = 0
    pid_activity = status_activity = interrupt_total = 0
    active_row = ""
    next
}

$1 == "@source" {
    if (!in_sample || NF != 2)
        invalid_contract()
    source_path = field_value(2)
    if (index(source_path, assigned_dir "/") != 1)
        invalid_contract()
    if (source_path ~ /\/proc_util$/) {
        proc_seen = 1
        proc_path = source_path
    }
    else if (source_path ~ /\/status$/) {
        status_seen = 1
        status_path = source_path
    }
    else if (source_path ~ /\/int_status$/) {
        interrupt_seen = 1
        interrupt_path = source_path
    }
    else if (source_path ~ /\/memory$/)
        memory_seen = 1
    else
        invalid_contract()
    next
}

$1 == "@end_source" {
    if (!in_sample || source_path == "")
        invalid_contract()
    source_path = ""
    next
}

$1 == "@end_sample" {
    if (source_path != "")
        invalid_contract()
    finish_sample()
    next
}

$1 == "@sampler_end" {
    if (in_sample || NF != 4)
        invalid_contract()
    sampler_end = field_value(2)
    sampler_end_seen = 1
    next
}

in_sample && source_path ~ /\/proc_util$/ && NF >= 9 &&
    ($1 == launcher_pid || $2 == launcher_pid) && $9 == "native_launcher" {
    activity = 0
    for (column = 3; column <= 8; column++) {
        if (!numeric($column))
            invalid_contract()
        activity += $column
    }
    if (activity > pid_activity) {
        pid_activity = activity
        active_row = $0
    }
    next
}

in_sample && source_path ~ /\/status$/ && /Utilisation:/ {
    value = $(NF)
    sub(/%$/, "", value)
    if (!numeric(value))
        invalid_contract()
    status_activity += value
    next
}

in_sample && source_path ~ /\/int_status$/ && $1 == "target" {
    found = 0
    for (column = 1; column < NF; column++) {
        if ($column == "received_int_times:") {
            if ($(column + 1) !~ /^[0-9]+$/)
                invalid_contract()
            interrupt_total += $(column + 1)
            found = 1
        }
    }
    if (!found)
        invalid_contract()
    next
}

END {
    if (invalid)
        exit 2
    if (in_sample || !sampler_start_seen || !sampler_end_seen || !identity_seen ||
        !baseline_seen || in_window_samples == 0 ||
        sampler_start >= access_start_ns || sampler_end < access_end_ns)
        exit 1
    print "launcher_pid=" launcher_pid
    print "assigned_device=" assigned_device
    print "sampler_start_ns=" sampler_start
    print "device_access_start_ns=" access_start_ns
    print "device_access_end_ns=" access_end_ns
    print "sampler_end_ns=" sampler_end
    print "in_window_samples=" in_window_samples
    if (pid_match) {
        print "activity_kind=exact_pid"
        print "activity_timestamp_ns=" pid_match_timestamp
        print "activity_path=" pid_match_path
        print "activity_sum=" pid_match_sum
        print "raw_sample=" pid_match_row
        exit 0
    }
    if (global_delta > 0) {
        print "activity_kind=" global_kind
        print "activity_timestamp_ns=" global_timestamp
        print "activity_path=" global_path
        print "activity_delta=" global_delta
        exit 0
    }
    exit 1
}
