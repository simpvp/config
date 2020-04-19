#!/bin/bash
set -euo pipefail

OUTPUT=${OUTPUT:="$HOME/filelists"}
WORLDS=${WORLDS:="world world_nether world_the_end"}

cd "$(dirname "$0")"

echo "Using outdir dir $OUTPUT"

mkdir -p "$OUTPUT"
mkdir -p "$OUTPUT/metadata"
mkdir -p "$OUTPUT/plain"
	
for WORLD in $WORLDS; do
	echo "Listing $WORLD"
	find "$WORLD" -mindepth 1 -type f -printf '%p\0\n' | sort -z > "$OUTPUT/plain/$WORLD.txt"
	find "$WORLD" -mindepth 1 -type f -printf '%p\tAccess: %a\tModified: %t\tSize: %s\0\n' | sort -z > "$OUTPUT/metadata/$WORLD.txt"
done

echo "All done"
