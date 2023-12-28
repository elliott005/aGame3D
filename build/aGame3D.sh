#!/bin/sh
echo -ne '\033c\033]0;Platformer 3d\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/aGame3D.x86_64" "$@"
