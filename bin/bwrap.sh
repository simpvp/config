#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(readlink -f $(dirname "$0"))
PWD=$(pwd)
if [[ "$SCRIPT_DIR" != "$PWD/bin" ]]; then
	echo "This script must be run from the root of the server's directory" >/dev/stderr
	exit 1
fi

if [ -n "${DEBUG:+x}" ]; then
	CMD=("$DEBUG" "$@")
elif [ -n "${DEBUG+x}" ]; then
	CMD=("/usr/bin/bash")
else
	CMD=("./bin/paper.sh")
fi

for DIR in plugins/*/ plugins/.paper-remapped/; do
	PLUGIN_MNTS+=("--bind" "$DIR" "/mc/$DIR")
done

exec bwrap \
	--ro-bind /bin /bin \
	--ro-bind /usr /usr \
	--ro-bind /etc /etc \
	--symlink /usr/lib /lib64 \
	--dev /dev \
	--proc /proc \
	--tmpfs /tmp \
	--chdir /mc \
	--unshare-all \
	--share-net \
	--die-with-parent \
	--bind . /mc \
	--ro-bind ./bin /mc/bin \
	--ro-bind ./plugins /mc/plugins \
	--ro-bind ./staging /mc/staging \
	"${PLUGIN_MNTS[@]}" \
	"${CMD[@]}"
