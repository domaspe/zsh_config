killport() {
    if (( $# != 1 )) || [[ "$1" != <-> ]] || (( 10#$1 < 1 || 10#$1 > 65535 )); then
        print -u2 -- "Usage: killport <port>"
        return 1
    fi

    local port="$1"
    local -a pids
    pids=($(lsof -t -i ":$port"))

    if (( ${#pids} == 0 )); then
        print -- "No process found using port $port"
        return 1
    fi

    kill -9 "${pids[@]}" || return 1
    print -- "Killed process IDs using port $port: ${pids[*]}"
}
