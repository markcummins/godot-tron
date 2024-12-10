#!/bin/sh
echo -ne '\033c\033]0;Demo6\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Tron.x86_64" "$@"
