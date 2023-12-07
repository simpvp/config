#!/usr/bin/env bash

exec socat TCP-LISTEN:25565,fork,reuseaddr TCP:simpvp.net:25565
