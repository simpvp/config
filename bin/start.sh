#!/bin/bash
set -euo pipefail

# Server will not automatically restart within this many seconds of already restarting
RESTART_LIMIT=60

SCRIPT_DIR=$(readlink -f $(dirname "$0"))
PWD=$(pwd)
if [[ "$SCRIPT_DIR" != "$PWD/bin" ]]; then
	echo "This script must be run from the root of the server's directory" >/dev/stderr
	exit 1
fi

while true
do
	TIME=$(date -u +%s)
	mv staging/* plugins/ || true
	if [ -f ./lock ]; then
		echo "Cannot start the server as another process is still running. Ensure the other server process is stopped before starting a new one."
		echo "Running PID: $(< ./lock)"
		exit 2
	fi

	echo -n "$PPID" > ./lock

	./bin/bwrap.sh || true


	LOCK=$(< ./lock)
	if [[ "$LOCK" == "$PPID" ]]; then
		rm ./lock
	else
		echo "Unable to delete lockfile. Got $LOCK != $PPID"
		exit 1
	fi

	if [ "$TIME" -ge "$(expr "$(date -u +%s)" - "$RESTART_LIMIT")" ]; then
		echo "Server trying to restart within $RESTART_LIMIT seconds. This is too soon, shutting down."
		exit
	fi

	echo "Restarting server"
done
