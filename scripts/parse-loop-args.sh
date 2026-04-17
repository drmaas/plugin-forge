#!/usr/bin/env bash

set -euo pipefail

loop_mode="loop"
found_loop_flag=0
found_no_loop_flag=0
objective_parts=()

for arg in "$@"; do
  case "$arg" in
    --loop)
      found_loop_flag=1
      ;;
    --no-loop)
      found_no_loop_flag=1
      loop_mode="no-loop"
      ;;
    --no-loop=*|--loop=*)
      echo "error=Invalid loop flag format: $arg"
      echo "hint=Use --no-loop as a standalone flag before the task description."
      exit 2
      ;;
    --*)
      # Preserve non-loop flags as part of the task objective text.
      objective_parts+=("$arg")
      ;;
    *)
      objective_parts+=("$arg")
      ;;
  esac
done

if [[ "$found_loop_flag" -eq 1 && "$found_no_loop_flag" -eq 1 ]]; then
  echo "error=Conflicting loop flags: --loop and --no-loop"
  echo "hint=Use only one loop flag. Default behavior is loop-on; pass --no-loop to disable it."
  exit 2
fi

objective="${objective_parts[*]:-}"

echo "loop_mode=$loop_mode"
echo "task_objective=$objective"