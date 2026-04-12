#!/usr/bin/env bash
# inject-mode.sh — SessionStart hook
# Reads the active development mode and outputs context for Claude.

set -euo pipefail

DATA_DIR="${CLAUDE_PLUGIN_DATA:-${HOME}/.claude/plugins/data/dev-mode}"
MODE_FILE="${DATA_DIR}/mode.json"

current_mode() {
  if [[ -f "${MODE_FILE}" ]]; then
    grep -Eo '"mode"\s*:\s*"[^"]*"' "${MODE_FILE}" \
      | head -n1 \
      | grep -Eo '"[^"]*"$' \
      | tr -d '"' || true
  fi
}

mode="$(current_mode || true)"

if [[ -z "${mode}" ]]; then
  cat <<'EOF'
[dev-mode] No development mode is set.
Run `/dev-mode:dm` to pick a mode before starting work.
EOF
  exit 0
fi

case "${mode}" in
  og)
    guidelines="$(cat <<'GUIDE'
### og Guidelines
1. Confirm requirements and constraints before coding.
2. Implement in small, reviewable increments.
3. Run required quality gates after implementation (type/static checks, lint/format, tests).
4. Fix regressions before handoff.
5. Request review with a concise change summary and validation results.
GUIDE
)"
    desc="implement → verify → review"
    workflow="$(cat <<'WORK'
When the user asks you to do implementation work, delegate to the **/dev-mode:builder** subagent — it owns the full execution loop (analyze → select skills → implement → validate → hand off for review). Do not do implementation yourself; let the builder run it.

When implementation is ready for review, the builder will delegate to **/dev-mode:reviewer**, which issues a verdict (Approve / Approve with suggestions / Request changes) and returns control to the builder if changes are needed.

You do not need to invoke these agents manually — use them as subagents when tasks arrive.
WORK
)"
    ;;
  tdd)
    guidelines="$(cat <<'GUIDE'
### tdd Guidelines
1. Start by writing a failing test that captures one behavior.
2. Implement the minimum code needed to pass that test.
3. Refactor only after tests are green.
4. Repeat in tight red/green/refactor cycles.
5. Keep tests behavior-focused and run full required gates before handoff.
GUIDE
)"
    desc="tests-first (red/green/refactor)"
    workflow="$(cat <<'WORK'
When the user asks for implementation, delegate to **/dev-mode:builder**. In this mode the builder writes a failing test first, implements to green, then hands off to **/dev-mode:reviewer**.

You do not need to invoke these agents manually — use them as subagents when tasks arrive.
WORK
)"
    ;;
  vibe)
    guidelines="$(cat <<'GUIDE'
### vibe Guidelines
1. Prioritize speed and feedback loops over ceremony.
2. Keep changes scoped so they can be validated quickly.
3. Maintain basic safety checks (at least targeted tests or smoke validation before handoff).
4. Document shortcuts or deferred hardening work explicitly.
5. Before merging, ensure follow-up work is tracked if full quality gates were deferred.
GUIDE
)"
    desc="fast iteration with reduced ceremony"
    workflow="$(cat <<'WORK'
When the user asks you to do implementation work, delegate to the **/dev-mode:builder** subagent. The builder should move quickly, keep scope tight, and still hand off to **/dev-mode:reviewer** before final delivery.

You do not need to invoke these agents manually — use them as subagents when tasks arrive.
WORK
)"
    ;;
  poc)
    guidelines="$(cat <<'GUIDE'
### poc Guidelines
1. Optimize for learning and risk reduction, not production readiness.
2. Prefer the simplest implementation that proves or disproves the idea.
3. Timebox exploration and capture explicit success/failure criteria.
4. Document assumptions, known gaps, and what would be required for productionization.
5. Do not ship POC code to production paths without a follow-up hardening pass.
GUIDE
)"
    desc="exploratory spike, not production-ready"
    workflow="$(cat <<'WORK'
When the user asks you to explore or prototype, delegate to **/dev-mode:builder**. The builder should optimize for learning, keep the work clearly non-production, and still use **/dev-mode:reviewer** if code changes are produced.

You do not need to invoke these agents manually — use them as subagents when tasks arrive.
WORK
)"
    ;;
  sdd)
    guidelines="$(cat <<'GUIDE'
### sdd Guidelines
1. Capture requirements, constraints, non-goals, and acceptance criteria.
2. Draft a concise spec (scope, contracts, edge cases, validation strategy).
3. Build an ordered implementation plan with dependencies.
4. Decompose into atomic tasks with explicit completion criteria.
5. Keep exactly one task in progress.
6. Maintain traceability from each change back to a requirement.
GUIDE
)"
    desc="spec-driven development"
    workflow="$(cat <<'WORK'
When the user asks for implementation, delegate to **/dev-mode:builder**. In this mode the builder should follow the full spec-driven loop before coding, then hand off to **/dev-mode:reviewer**.

You do not need to invoke these agents manually — use them as subagents when tasks arrive.
WORK
)"
    ;;
  brainstorm)
    guidelines="$(cat <<'GUIDE'
### brainstorm Guidelines
1. Focus on framing the problem, generating options, and comparing tradeoffs.
2. Explore concrete approaches, constraints, risks, and likely implementation shapes.
3. Produce sketches, recommendations, or lightweight plans without editing files.
4. Stay in discussion mode unless the user explicitly switches to an implementation-oriented mode.
5. End with a recommended direction or a short set of viable options.
GUIDE
)"
    desc="explore ideas without writing code"
    workflow="$(cat <<'WORK'
Do **not** write code, edit files, or delegate to **/dev-mode:builder** in this mode. Stay in ideation, planning, architecture discussion, and tradeoff analysis.

If the user wants to move from ideation to execution, have them switch to an implementation-oriented mode such as `oneoff`, `og`, `tdd`, `vibe`, `poc`, or `sdd`.
WORK
)"
    ;;
  oneoff)
    guidelines="$(cat <<'GUIDE'
### oneoff Guidelines
1. Default to immediate execution of the user's request.
2. Skip heavy planning and ceremony unless ambiguity or risk makes it necessary.
3. Make the smallest coherent change that fully satisfies the ask.
4. Run the minimum appropriate validation for the touched surface.
5. If code changes are made, finish with review before final delivery.
GUIDE
)"
    desc="directly implement the user's request"
    workflow="$(cat <<'WORK'
When the user asks for work, delegate immediately to **/dev-mode:builder**. In this mode the builder should implement directly, avoid unnecessary planning overhead, and hand off to **/dev-mode:reviewer** once the requested change is ready.

You do not need to invoke these agents manually — use them as subagents when tasks arrive.
WORK
)"
    ;;
  *)
    echo "[dev-mode] Active mode: ${mode} (unrecognized — run /dev-mode:dm to reset)"
    exit 0
    ;;
esac

cat <<EOF
[dev-mode] Active development mode: **${mode}** — ${desc}

${guidelines}

### How to work in this mode

${workflow}

### Skills (used internally by builder and reviewer)
| Skill | When to use |
|-------|-------------|
| /dev-mode:orchestrator | Multi-step or cross-module work |
| /dev-mode:librarian    | Navigating unfamiliar code, tracing data flows |
| /dev-mode:coder        | Core implementation and refactoring |
| /dev-mode:tester       | Writing or updating tests, TDD cycles |
| /dev-mode:gatekeeper   | Pre-handoff quality gate validation |
| /dev-mode:architect    | System design and architectural decisions |
| /dev-mode:code-review  | Full code review methodology (used by reviewer) |

To switch modes, run \`/dev-mode:dm\`.
EOF
