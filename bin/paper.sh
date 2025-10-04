#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(readlink -f $(dirname "$0"))
PWD=$(pwd)
if [[ "$SCRIPT_DIR" != "$PWD/bin" ]]; then
	echo "This script must be run from the root of the server's directory" >/dev/stderr
	exit 1
fi

exec nice -n -20 -- \
	java -server -Dlog4j.configurationFile=./Log4j2.xml -DIReallyKnowWhatIAmDoingISwear=true \
	-Xms6G -Xmx32G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=40 -XX:G1MaxNewSizePercent=50 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=15 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=20 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 \
	-jar ./bin/paper-1.21.8-25.jar
