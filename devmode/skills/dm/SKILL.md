---
name: dm
description: Switch the active development mode. Use when the user runs /devmode:dm or asks to change, set, pick, or view the development mode. Shows a quick-pick submenu of modes (og, tdd, vibe, poc, sdd, brainstorm, oneoff).
argument-hint: [set <og|tdd|vibe|poc|sdd|brainstorm|oneoff> | status | list]
allowed-tools: [Bash]
---

# Development Mode Switcher

The user invoked `/devmode:dm $ARGUMENTS`.

Use the helper from a known path:

```bash
DM_CMD="${CLAUDE_PLUGIN_ROOT}/bin/dm"
```

## Instructions

### Step 1 — Parse arguments

If `$ARGUMENTS` is non-empty, handle directly:

- `set <mode>` → run `"${CLAUDE_PLUGIN_ROOT}/bin/dm" set <mode>` and confirm the switch. Done.
- `status` → run `"${CLAUDE_PLUGIN_ROOT}/bin/dm" status` and display the result. Done.
- `list` → run `"${CLAUDE_PLUGIN_ROOT}/bin/dm" list` and display the result. Done.

If `$ARGUMENTS` is empty, proceed to Step 2.

### Step 2 — Show the mode picker

1. Run `"${CLAUDE_PLUGIN_ROOT}/bin/dm" --json status` to get the current mode.
2. Use the `ask_user` tool to present a single-select form:

```json
{
  "message": "Select development mode",
  "requestedSchema": {
    "properties": {
      "mode": {
        "type": "string",
        "title": "Development Mode",
        "description": "Choose the workflow for this session",
        "oneOf": [
          { "const": "og",   "title": "og — light plan → implement → verify → review" },
          { "const": "tdd",  "title": "tdd — tests-first (red/green/refactor)" },
          { "const": "vibe", "title": "vibe — fast iteration with reduced ceremony" },
          { "const": "poc",  "title": "poc — exploratory spike, not production-ready" },
          { "const": "sdd",  "title": "sdd — spec-driven development" },
          { "const": "brainstorm", "title": "brainstorm — explore ideas without writing code" },
          { "const": "oneoff", "title": "oneoff — directly implement the user's request" }
        ],
        "default": "<current-mode-from-step-1>"
      }
    },
    "required": ["mode"]
  }
}
```

Set `default` to the current mode from `"${CLAUDE_PLUGIN_ROOT}/bin/dm" --json status`. If no mode is set, omit `default`.

3. After the user selects, run `"${CLAUDE_PLUGIN_ROOT}/bin/dm" set <selected-mode>`.
4. Confirm with a brief message: e.g., "✓ Mode set to **sdd** (spec-driven development)."

### Step 3 — If user declines/cancels

Print the current mode and exit without making changes.

## Workflow After Mode Selection

Once a mode is set, Claude automatically follows the selected workflow:

- `brainstorm` → stay in discussion/ideation mode and do not write code
- `oneoff`, `og`, `tdd`, `vibe`, `poc`, `sdd` → Claude routes implementation to `/devmode:builder`
- when implementation is ready → builder delegates to `/devmode:reviewer`
- if reviewer requests changes → builder iterates and resubmits

The user does not invoke builder or reviewer directly.
