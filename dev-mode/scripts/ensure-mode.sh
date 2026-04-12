#!/usr/bin/env bash
# ensure-mode.sh — UserPromptSubmit hook
# Reminds the user to set a mode if none is configured.
# Outputs nothing (exit 0) when a mode is already set.

set -euo pipefail

DATA_DIR="${CLAUDE_PLUGIN_DATA:-${HOME}/.claude/plugins/data/dev-mode}"
MODE_FILE="${DATA_DIR}/mode.json"

if [[ ! -f "${MODE_FILE}" ]]; then
  echo "[dev-mode] No development mode is set. Run \`/dev-mode:dm\` to pick one."
fi
# If mode file exists, stay silent — don't nag on every prompt.
