#!/bin/bash
set -euo pipefail

get_lock() {
	if [ -f ./lock ]; then
		LOCK=$(< ./lock)
		if [[ "$LOCK" == "$PPID" ]]; then
			echo "Already had lock on current PID"
			return
		fi

		if  [ -d "/proc/$LOCK" ]; then
			echo "Cannot start the server as another process is still running. Ensure the other server process is stopped before starting a new one."
			echo "Running PID: $LOCK"
			return 2
		else
			echo "Already had lock file for PID $LOCK."
			echo "No such process found, overwriting lock."
		fi
	fi

	echo -n "$PPID" > ./lock
	echo "Created lock for pid $PPID"
}

delete_lock() {
	LOCK=$(< ./lock) || return 0
	if [[ "$LOCK" == "$PPID" ]]; then
		rm ./lock
	else
		echo "Unable to delete lockfile. Got $LOCK != $PPID"
		return 1
	fi
}

exit() {
	delete_lock
}
trap exit EXIT

SCRIPT_DIR=$(readlink -f $(dirname "$0"))
PWD=$(pwd)
if [[ "$SCRIPT_DIR" != "$PWD/bin" ]]; then
	echo "This script must be run from the root of the server's directory" >/dev/stderr
	exit 1
fi

# Server will not automatically restart within this many seconds of already restarting
RESTART_LIMIT=60

while true
do
	TIME=$(date -u +%s)
	mv staging/* plugins/ || true

	get_lock

	./bin/bwrap.sh || true

	delete_lock

	if [ "$TIME" -ge "$(expr "$(date -u +%s)" - "$RESTART_LIMIT")" ]; then
		echo "Server trying to restart within $RESTART_LIMIT seconds. This is too soon, shutting down."
		exit
	fi

	echo "Restarting server"
done
