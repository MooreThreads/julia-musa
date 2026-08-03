function numeric(value) {
    return value ~ /^([0-9]+([.][0-9]*)?|[.][0-9]+)$/
}

function reject_contract() {
    invalid = 1
    exit 2
}

BEGIN {
    if (launcher_pid !~ /^[1-9][0-9]*$/)
        reject_contract()
}

$1 == "@source" {
    if (NF != 3 ||
        $2 !~ /^\/proc\/driver\/musa\/gpu[0-9]+\/proc_util$/ ||
        $3 !~ /^mtgpu\.[0-9]+$/)
        reject_contract()
    source_count++
    proc_util_path = $2
    node_label = $3
    header_seen = 0
    next
}

$1 == "Pid" {
    if (source_count == 0 || NF != 9 || $2 != "VPid" || $3 != "Total" ||
        $4 != "2D" || $5 != "TA" || $6 != "3D" || $7 != "CMP" ||
        $8 != "TRANSFER" || $9 != "PidName")
        reject_contract()
    header_seen = 1
    next
}

source_count > 0 && header_seen && NF >= 9 &&
    ($1 == launcher_pid || $2 == launcher_pid) && $9 == "native_launcher" {
    pid_matches++
    activity = 0
    for (column = 3; column <= 8; column++) {
        if (!numeric($column))
            reject_contract()
        activity += $column
    }
    if (activity > 0) {
        active_matches++
        matched_path = proc_util_path
        matched_node = node_label
        matched_activity = activity
        matched_row = $0
    }
    next
}

END {
    if (invalid)
        exit 2
    if (source_count == 0 || pid_matches != 1 || active_matches != 1)
        exit 1
    print "launcher_pid=" launcher_pid
    print "node_label=" matched_node
    print "proc_util_path=" matched_path
    print "activity_sum=" matched_activity
    print "raw_sample=" matched_row
}
