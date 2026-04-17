---
description: Default implementation workflow with lightweight planning and full review handoff.
argument-hint: [--no-loop] [task description]
---

Run the devmode `/build` workflow.

First, parse loop flags and objective from the invocation:

```!
bash "${CLAUDE_PLUGIN_ROOT}/scripts/parse-loop-args.sh" $ARGUMENTS
```

Treat parser output as authoritative:

- `loop_mode=loop`: use standard Ralph Loop iteration.
- `loop_mode=no-loop`: run a single pass and hand off without iterative loop behavior.
- `task_objective=...`: use this as the objective text (do not treat `--no-loop` as objective content).

Use `devmode-builder` as the implementation owner with this contract:

1. Create a lightweight plan (scope, touched files, validation approach).
2. Implement end-to-end.
3. Run type/lint checks and the strongest practical tests for changed surfaces.
4. Hand off to `devmode-reviewer` for a verdict.
5. If review requests changes, iterate until approved.

Use `devmode-orchestrator`, `devmode-librarian`, and `devmode-coder` skills as needed.
Load `devmode-tester` and `devmode-gatekeeper` before validation.

If `task_objective` is non-empty, treat it as the active task objective.
