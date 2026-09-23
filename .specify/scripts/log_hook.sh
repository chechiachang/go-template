#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 '\$speckit.command' <event>" >&2
  exit 2
fi

command_name="$1"
event="$2"

if [[ ! "$command_name" =~ ^\$speckit\.[[:alnum:]_-]+$ ]]; then
  echo "invalid Spec Kit command: $command_name" >&2
  exit 2
fi

case "$event" in
  before_tasks|after_tasks|before_implement|after_implement)
    ;;
  *)
    echo "invalid hook event: $event" >&2
    exit 2
    ;;
esac

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(cd -- "$script_dir/../.." && pwd)"
log_file="$project_root/logs/speckit-log.csv"

mkdir -p -- "$(dirname -- "$log_file")"

if [[ ! -e "$log_file" ]]; then
  printf 'timestamp,command,event\n' > "$log_file"
fi

timestamp="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
printf '%s,"%s","%s"\n' "$timestamp" "$command_name" "$event" >> "$log_file"
