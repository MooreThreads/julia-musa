BEGIN {
    if (launcher_pid !~ /^[1-9][0-9]*$/ || device_name !~ /S5000/ ||
        proc_util_path !~ /^\/proc\/driver\/musa\/gpu[^/]*\/proc_util$/)
        exit 2
}

function numeric(value) {
    return value ~ /^([0-9]+([.][0-9]*)?|[.][0-9]+)$/
}

NF >= 9 && ($1 == launcher_pid || $2 == launcher_pid) && $9 == "native_launcher" {
    total = 0
    for (field = 3; field <= 8; field++) {
        if (!numeric($field))
            next
        total += $field
    }
    if (total > 0) {
        print "launcher_pid=" launcher_pid
        print "device_name=" device_name
        print "proc_util_path=" proc_util_path
        print "activity_sum=" total
        print "raw_sample=" $0
        found = 1
        exit 0
    }
}

END {
    if (!found)
        exit 1
}
