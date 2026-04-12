# dev-mode — Claude Code Plugin

A snappy development mode switcher for Claude Code. Pick your workflow with a quick-pick submenu — no repo files are ever mutated. Includes a full skill-first workflow system with builder and reviewer agents and 7 core skills.

## Features

- **`/dev-mode:dm`** — opens an instant mode picker (like the model switcher)
- **Persistent state** — stored in `~/.claude/plugins/data/dev-mode/mode.json`, never in your repo
- **Auto-injected context** — active mode + guidelines + agent/skill roster injected at every session start
- **CLI helper** — `dm` binary available in any Bash tool call while the plugin is enabled
- **`/dev-mode:builder`** — implementation agent with skill-first execution loop
- **`/dev-mode:reviewer`** — review agent with systematic evaluation methodology
- **7 core skills** — architect, code-review, coder, gatekeeper, librarian, orchestrator, tester

## Modes

| Mode | Description |
|------|-------------|
| `og` | implement → verify → review |
| `tdd` | tests-first (red/green/refactor) |
| `vibe` | fast iteration with reduced ceremony |
| `poc` | exploratory spike, not production-ready |
| `sdd` | spec-driven development |

## Installation

### From this repository's marketplace

```text
/plugin marketplace add drmaas/coding-agent-template
/plugin install dev-mode@coding-agent-template
/reload-plugins
```

### From a local directory (development/testing)

```bash
claude --plugin-dir ./dev-mode
```

### From another marketplace

If `dev-mode` is later published to a remote marketplace, install it with:

```text
/plugin install dev-mode@<marketplace-name>
```

## Usage

### Pick a mode (submenu)

```
/dev-mode:dm
```

Presents a radio-button form. The current mode is pre-selected.

### Set mode directly

```
/dev-mode:dm set sdd
/dev-mode:dm set tdd
```

### Check current mode

```
/dev-mode:dm status
```

### List all modes

```
/dev-mode:dm list
```

### CLI (in Bash tool or terminal)

```bash
dm status
dm list
dm set sdd
dm --json status
dm --json set tdd
```

### Use the workflow

Once a mode is set, just give Claude a task. It will automatically:
1. Delegate implementation to `/dev-mode:builder`
2. Builder delegates review to `/dev-mode:reviewer` when ready
3. Reviewer returns a verdict; builder iterates if needed

You don't invoke builder or reviewer directly.

## Agents

The builder and reviewer agents are invoked automatically by Claude based on the active mode — you don't call them directly.

### `/dev-mode:builder`

Invoked by Claude when implementation work is needed. Runs a skill-first execution loop:

1. Analyze → 2. Select skills → 3. Implement → 4. Validate → 5. Delegate to reviewer

Adapts behavior per active mode (og, tdd, vibe, poc, sdd).

### `/dev-mode:reviewer`

Invoked by the builder when implementation is ready for review. Uses the `/dev-mode:code-review` skill and issues one of:
- **Approve**
- **Approve with suggestions**
- **Request changes** (returns to builder)

## Skills

All skills are namespaced under `/dev-mode:`. They load automatically based on context, or you can name them explicitly.

| Skill | When to use |
|-------|-------------|
| `/dev-mode:orchestrator` | Multi-step or cross-module work |
| `/dev-mode:librarian`    | Navigating unfamiliar code, tracing data flows |
| `/dev-mode:coder`        | Core implementation and refactoring |
| `/dev-mode:tester`       | Writing or updating tests, TDD cycles |
| `/dev-mode:gatekeeper`   | Pre-handoff quality gate validation |
| `/dev-mode:architect`    | System design and architectural decisions |
| `/dev-mode:code-review`  | Full code review methodology (used by reviewer) |

**Not included** (install separately if needed):
- `playwright-cli` — requires the `playwright-cli` binary
- `ux-designer` — domain-specific, optional for frontend work

## How It Works

1. **`bin/dm`** — standalone bash script that reads/writes `$CLAUDE_PLUGIN_DATA/mode.json`. No `jq` required.
2. **`skills/dm/SKILL.md`** — slash command that uses the `ask_user` enum picker, then calls `dm set`.
3. **`agents/builder.md`** — builder agent with mode-aware skill-first execution loop.
4. **`agents/reviewer.md`** — reviewer agent that loads the code-review skill.
5. **`skills/`** — 8 skills total: dm + 7 core workflow skills.
6. **`hooks/hooks.json`** — two hooks:
   - `SessionStart`: injects current mode + guidelines + agent/skill roster
   - `UserPromptSubmit`: reminds you to set a mode if none is configured (only fires once, until a mode is set)
7. **`scripts/inject-mode.sh`** — formats the mode context, agent names, and skill table for Claude
8. **`scripts/ensure-mode.sh`** — silent when mode is set, reminder when it isn't

## Development

```bash
# Test the CLI helper locally
export CLAUDE_PLUGIN_DATA=/tmp/dev-mode-test
./dev-mode/bin/dm set sdd
./dev-mode/bin/dm status
./dev-mode/bin/dm list
./dev-mode/bin/dm --json status

# Test hooks
CLAUDE_PLUGIN_DATA=/tmp/dev-mode-test CLAUDE_PLUGIN_ROOT=./dev-mode ./dev-mode/scripts/inject-mode.sh
CLAUDE_PLUGIN_DATA=/tmp/test-no-mode CLAUDE_PLUGIN_ROOT=./dev-mode ./dev-mode/scripts/ensure-mode.sh

# Load the plugin in Claude Code
claude --plugin-dir ./dev-mode
```

## Packaging for Remote Users

`dev-mode` is packaged for remote installation by listing it in the repo root marketplace catalog:

- Plugin manifest: `dev-mode/.claude-plugin/plugin.json`
- Marketplace entry: `.claude-plugin/marketplace.json`

For a release:

1. Update `dev-mode/.claude-plugin/plugin.json`
2. Update the matching entry in `.claude-plugin/marketplace.json` if metadata changed
3. Push the repository so remote users can install or update through `/plugin`

## Contributing

Contributions welcome. Open a PR with a clear description of the change and why it's needed.

## License

MIT — see [LICENSE](./LICENSE)
