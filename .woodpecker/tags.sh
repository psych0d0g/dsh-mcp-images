#!/bin/sh
# Print the image tags for one image dir: "<tag>,latest", where <tag> is the
# Dockerfile's version ARGs joined in the order given (first one bare, the
# rest as <prefix><value>), so every version bump produces a new tag.
# Usage: tags.sh <dir> <ARG> [<prefix>=<ARG> ...]
set -eu
dir=$1; shift
arg() { sed -n "s/^ARG $1=//p" "$dir/Dockerfile" | head -1; }
tag=$(arg "$1"); shift
[ -n "$tag" ] || { echo "no ARG value in $dir/Dockerfile" >&2; exit 1; }
for spec in "$@"; do
  v=$(arg "${spec#*=}")
  [ -n "$v" ] || { echo "no ARG ${spec#*=} in $dir/Dockerfile" >&2; exit 1; }
  tag="$tag-${spec%%=*}$v"
done
printf '%s,latest\n' "$tag"
