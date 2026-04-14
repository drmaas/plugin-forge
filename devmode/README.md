# devmode

`devmode` is a Claude Code plugin that lets you switch how Claude executes work in the current session.

## Goals

`devmode` is designed to:

- let you switch workflows quickly (`/devmode:dm`)
- keep mode state outside your repository
- inject clear mode behavior at session start
- ensure implementation work follows a builder + reviewer lifecycle
- support uninterrupted completion behavior through Ralph Loop (also referred to as Ralph mode)

## Capabilities

| Capability          | What it gives you                                                                                                          |
| ------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| Mode selection      | Pick `og`, `tdd`, `vibe`, `poc`, `sdd`, `brainstorm`, or `oneoff` per session                                |
| Mode persistence    | Stores selected mode in `${CLAUDE_PLUGIN_DATA}/mode.json` (fallback: `${HOME}/.claude/plugins/data/devmode/mode.json`) |
| Workflow injection  | SessionStart hook injects mode-specific behavior and internal skill map                                                    |
| Safety reminder     | UserPromptSubmit hook reminds you to pick a mode if none is set                                                            |
| Structured delivery | Implementation modes route through `/devmode:builder` then `/devmode:reviewer`                                         |

## Install

### From the `plugin-forge` marketplace

```text
/plugin marketplace add drmaas/plugin-forge
/plugin install devmode@plugin-forge
/reload-plugins
```

### From a local directory

```bash
claude --plugin-dir ./devmode
```

## Quick Start

1. Choose a mode:

```text
/devmode:dm
```

2. Or set one directly:

```text
/devmode:dm set oneoff
```

3. Give Claude your task.

`devmode` injects the active flow automatically.

## Command Reference

Use the command skill:

```text
/devmode:dm
/devmode:dm status
/devmode:dm list
/devmode:dm set sdd
/devmode:dm explain sdd
```

Use the CLI helper in Bash-enabled contexts:

```bash
dm status
dm list
dm set tdd
dm explain tdd
dm --json status
```

For plugin hooks or skill authoring, use the known path:

```bash
"${CLAUDE_PLUGIN_ROOT}/bin/dm" status
"${CLAUDE_PLUGIN_ROOT}/bin/dm" --json status
```

## How the Flow Works

1. You set a mode with `/devmode:dm`.
2. The mode is persisted in `mode.json` outside the repo.
3. At session start, `inject-mode.sh` injects mode behavior.
4. For implementation-oriented modes, work routes to `/devmode:builder`.
5. Builder implements and validates based on active mode rules.
6. Builder hands off to `/devmode:reviewer`.
7. Reviewer returns `Approve`, `Approve with suggestions`, or `Request changes`.
8. If changes are requested, builder iterates and resubmits until complete.

## Ralph Loop (Ralph Mode)

Ralph Loop is the execution continuity rule for implementation work. "Ralph mode" is used here as a shorthand alias for the same behavior.

It means:

- do not stop at analysis-only checkpoints
- continue until implementation is complete and verified
- if checks fail, fix and re-run
- if review requests changes, implement feedback and loop again
- finish only when delivery is complete

Ralph Loop applies to implementation-oriented modes (`og`, `tdd`, `vibe`, `poc`, `sdd`, `oneoff`), not `brainstorm`.

## Choosing a Mode Quickly

| If you need...                  | Use            | Why                                       |
| ------------------------------- | -------------- | ----------------------------------------- |
| Lightweight default execution   | `og`         | Short plan, then implement/verify/review  |
| Strict test-first discipline    | `tdd`        | Red/green/refactor loop                   |
| Fast iteration                  | `vibe`       | Reduced ceremony, quick feedback loops    |
| Exploration spike               | `poc`        | Learn quickly without production claims   |
| Full spec-driven flow           | `sdd`        | Requirements/spec/tasks traceability      |
| Ideation only                   | `brainstorm` | Discussion and tradeoffs, no code changes |
| Minimal ceremony implementation | `oneoff`     | Direct execution for clear requests       |

## Mode Flows (Step by Step)

### `og` flow (light plan -> implement -> verify -> review)

1. Confirm scope and constraints.
2. Build a lightweight plan (surfaces, order, validation).
3. Implement in small increments.
4. Run required quality gates (type/static, lint/format, tests).
5. Fix issues before handoff.
6. Submit to reviewer and iterate if needed.

### `tdd` flow (tests-first)

1. Write a failing test for one behavior.
2. Implement minimum code to pass.
3. Refactor only after green tests.
4. Repeat red/green/refactor cycles.
5. Run required gates before handoff.
6. Submit to reviewer and iterate if needed.

### `vibe` flow (fast iteration)

1. Keep scope tight and move quickly.
2. Implement the highest-value slice first.
3. Run at least targeted validation or smoke checks.
4. Track deferred hardening explicitly.
5. Hand off for reviewer verdict.
6. Apply feedback until done.

### `poc` flow (exploratory, non-production)

1. Define what you are trying to prove.
2. Build the simplest spike that validates the idea.
3. Timebox exploration.
4. Document assumptions, gaps, and productionization needs.
5. Run basic safety validation.
6. Hand off for reviewer verdict if code changed.

### `sdd` flow (spec-driven)

1. Capture requirements, constraints, non-goals, acceptance criteria.
2. Draft concise spec (scope, contracts, edge cases, validation).
3. Build phased implementation plan with dependencies.
4. Decompose into atomic tasks with explicit completion criteria.
5. Keep exactly one task in progress.
6. Implement with requirement-to-change traceability.
7. Run required quality gates.
8. Hand off for reviewer verdict and close feedback loop.

### `brainstorm` flow (non-coding)

1. Frame the problem clearly.
2. Generate options and compare tradeoffs.
3. Provide recommendations or lightweight plans.
4. Do not edit files or write implementation code.
5. When ready to execute, switch to an implementation mode.

### `oneoff` flow (direct implementation)

1. Start implementation immediately.
2. Skip heavy planning unless risk or ambiguity requires it.
3. Make the smallest coherent change that satisfies the request.
4. Run minimum appropriate validation for touched surfaces.
5. Hand off for reviewer verdict.
6. Apply feedback until complete.

## Builder and Reviewer Lifecycle

You typically use only `/devmode:dm`. The builder and reviewer are internal workflow components:

- `/devmode:builder` owns implementation execution
- `/devmode:reviewer` is the sole review authority

The lifecycle for implementation modes is:

1. Builder implements and validates.
2. Reviewer returns a verdict.
3. Builder resolves requested changes.
4. Loop continues until reviewer approves and delivery is complete.

## Main Components

| Component                  | Purpose                                 |
| -------------------------- | --------------------------------------- |
| `skills/dm/`             | Mode picker and mode command behavior   |
| `agents/builder.md`      | Implementation owner workflow           |
| `agents/reviewer.md`     | Review authority workflow               |
| `scripts/inject-mode.sh` | SessionStart mode injection             |
| `scripts/ensure-mode.sh` | Prompt-time reminder when mode is unset |
| `bin/dm`                 | Mode state helper and CLI               |

## Troubleshooting

### Mode does not seem active

Run:

```text
/devmode:dm status
```

### Plugin installed but behavior not updated

Run:

```text
/reload-plugins
```

### I want ideation only (no code)

Set:

```text
/devmode:dm set brainstorm
```

### I am done brainstorming and want implementation

Switch to an implementation mode, for example:

```text
/devmode:dm set oneoff
```
