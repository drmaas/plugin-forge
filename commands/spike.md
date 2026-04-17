---
description: Exploratory implementation workflow for rapid validation of uncertain ideas.
argument-hint: [--no-loop] [task description]
---

Run the devmode `/spike` workflow.

First, parse loop flags and objective from the invocation:

```!
bash "${CLAUDE_PLUGIN_ROOT}/scripts/parse-loop-args.sh" $ARGUMENTS
```

Treat parser output as authoritative:

- `loop_mode=loop`: use standard Ralph Loop iteration.
- `loop_mode=no-loop`: run a single pass and hand off without iterative loop behavior.
- `task_objective=...`: use this as the objective text (do not treat `--no-loop` as objective content).

Use `devmode-builder` as the implementation owner with this contract:

1. Keep scope intentionally narrow.
2. Move fast to validate assumptions and feasibility.
3. Mark tradeoffs, risks, and non-production shortcuts clearly.
4. Run lightweight validation unless the user requests production hardening.
5. Hand off to `devmode-reviewer` if code quality decisions are needed.

Prefer `devmode-librarian` for discovery and `devmode-coder` for rapid implementation.

If `task_objective` is non-empty, treat it as the active task objective.
