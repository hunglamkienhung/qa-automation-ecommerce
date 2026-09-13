#!/usr/bin/env bash
# Run mini-shop against a local SQLite file, or stop it.
#   ./serve.sh up | down | status
# Detached with setsid so it survives the launching shell (a WSL session tears
# down plain-nohup children on exit). The WAL store must live on a native Linux
# filesystem for a WSL reader to memory-map it -- set MINI_SHOP_DB to a /tmp path.
set -euo pipefail
cd "$(dirname "$0")"
PORT="${MINI_SHOP_PORT:-8090}"
export MINI_SHOP_PORT="${PORT}"
LOG="${MINI_SHOP_LOG:-/tmp/mini-shop-${PORT}.log}"
PIDFILE="/tmp/mini-shop-${PORT}.pid"
free_port() {
  # Kill whatever still holds the port, however it was launched. A stale server
  # left on this port from an earlier run keeps answering, so a fresh bind that
  # silently fails looks "up" while serving an empty store -- turning every
  # downstream case into a spurious Blocked. Freeing the port is the only
  # reliable guard: pkill-by-name misses a server launched as bare
  # `node server.js`, and a leftover pidfile may not name a live process.
  if command -v fuser >/dev/null 2>&1; then fuser -k "${PORT}/tcp" 2>/dev/null || true
  elif command -v lsof >/dev/null 2>&1; then lsof -ti tcp:"${PORT}" 2>/dev/null | xargs -r kill 2>/dev/null || true; fi
}
case "${1:-up}" in
  up)
    [ -f "${PIDFILE}" ] && kill "$(cat "${PIDFILE}")" 2>/dev/null || true
    pkill -f "mini-shop/server.js" 2>/dev/null || true
    free_port
    sleep 0.4
    # Fresh store every run: scenarios assert on deltas and use fixed keys
    # (idempotency, single-use coupons), so a run must start from the seed --
    # the same reason chain.sh redeploys anvil fresh.
    if [ -n "${MINI_SHOP_DB:-}" ]; then rm -f "${MINI_SHOP_DB}" "${MINI_SHOP_DB}-shm" "${MINI_SHOP_DB}-wal" 2>/dev/null || true; else rm -rf ./data 2>/dev/null || true; fi
    setsid nohup node "$(pwd)/server.js" > "${LOG}" 2>&1 < /dev/null &
    echo $! > "${PIDFILE}"; disown || true
    for i in $(seq 1 40); do curl -sf "http://127.0.0.1:${PORT}/categories" >/dev/null 2>&1 && break; sleep 0.2; done
    curl -s "http://127.0.0.1:${PORT}/categories" >/dev/null && echo "mini-shop up on ${PORT} (db ${MINI_SHOP_DB:-./data/mini-shop.db})" || { echo "did not come up"; cat "${LOG}"; exit 1; }
    ;;
  down) [ -f "${PIDFILE}" ] && kill "$(cat "${PIDFILE}")" 2>/dev/null || true; rm -f "${PIDFILE}"; echo "stopped" ;;
  status) curl -s "http://127.0.0.1:${PORT}/categories" && echo || echo "not running" ;;
  *) echo "usage: $0 up|down|status" >&2; exit 2 ;;
esac
