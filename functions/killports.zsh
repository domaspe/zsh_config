# Kill processes on dev ports (3000, 3001, 3002)
killports() {
  for port in 3000 3001 3002; do
    local pids=$(lsof -ti tcp:"$port" 2>/dev/null)
    for pid in $pids; do
      # Walk up the process tree to find the watcher parent (nx serve, etc.)
      local tree_root=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
      while [[ -n "$tree_root" ]] && (( tree_root > 1 )); do
        local cmd=$(ps -o comm= -p "$tree_root" 2>/dev/null)
        [[ "$cmd" == sh || "$cmd" == node ]] || break
        pid=$tree_root
        tree_root=$(ps -o ppid= -p "$tree_root" 2>/dev/null | tr -d ' ')
      done
      # Kill process group first, fall back to single process
      kill -9 -"$pid" 2>/dev/null || kill -9 "$pid" 2>/dev/null
    done
  done
  # Kill known dev tool processes that may respawn on watched ports
  pkill -9 -f "nx run-many" 2>/dev/null
  pkill -9 -f "nest start" 2>/dev/null
  pkill -9 -f "dist/apps/backend/main" 2>/dev/null
  pkill -9 -f "vite" 2>/dev/null
  echo "Done"
}
