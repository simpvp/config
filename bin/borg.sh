#!/usr/bin/env bash

set -euo pipefail

# Init repo with
# ./borg.sh init --encryption repokey --append-only

# Add an entry to .ssh/config for where to find the backup location, for
# example:
# Host borg
#   User borg
#   HostName my.backup.server
#   Port 22

# We only want to add the --progress option if running in a terminal, not if
# it's run as a cronjob
if [ -t 0 ]; then
	PROGRESS=("--progress")
else
	PROGRESS=()
fi

PASSFILE=~/.borg_simpvp
chmod 0600 "$PASSFILE"
export BORG_PASSPHRASE=$(cat "$PASSFILE")
export BORG_REPO='ssh://borg/mnt/borg/simpvp'

# If arguments are supplied then run those with borg with the right environment
# variables set, letting you do for example ./borg.sh list
if [ "$#" -gt 0 ]; then
	echo "borg $@"
	borg "$@"
	exit
fi

borg create -v --stats "${PROGRESS[@]}" \
	--compression lzma,6 \
	--upload-ratelimit 5000 \
	::'mc_by_{hostname}_{utcnow}_UTC_Borg_{borgversion}' \
	/home/mc

borg prune -v --list \
	--keep-within=60d \
	--keep-daily=15 \
	--keep-monthly=10000 \
	--keep-yearly=10000 \
	--glob-archives 'mc_*'
