# coding-agent-template

A generic, skill-first template for configuring Claude Code workflows with clear ownership boundaries and low token overhead.

This repository also acts as a **Claude plugin marketplace repo**: it contains installable plugins and a root marketplace catalog so remote users can add the repo with `/plugin marketplace add` and install plugins with `/plugin install`.

## Project Overview

This repository provides a reusable baseline for agent-driven development with a two-owner model supplied by the `dev-mode` plugin:

- `/dev-mode:builder` owns implementation.
- `/dev-mode:reviewer` owns review.

Specialized work is handled through plugin skills loaded by the active owner rather than adding many permanent owner roles.

The canonical operating policy lives in `CLAUDE.md`. Development mode selection, mode-specific process guidance, builder/reviewer agents, and workflow skills live in `dev-mode/`.

## Goals

- Keep implementation and review responsibilities separate.
- Encourage modular, skill-first execution.
- Make development mode switching fast and non-destructive.
- Provide a portable template that can be adapted across repositories.

## Design

The template is designed around a small set of principles:

- **Two-owner model:** one owner executes implementation, one owner performs review.
- **Skill-first specialization:** load only the capabilities needed for the current step.
- **Plugin-owned modes:** the `dev-mode` plugin stores active mode outside the repo and injects the process each mode should follow.
- **Single policy source:** shared workflow policy is centralized in `CLAUDE.md`.

## Plugins in This Repository

| Plugin | Path | Purpose |
| --- | --- | --- |
| `dev-mode` | `dev-mode/` | Development mode picker and workflow plugin. Provides `/dev-mode:dm`, mode-aware hooks, `/dev-mode:builder`, `/dev-mode:reviewer`, and the core workflow skills used by those agents. |

**Not plugins:** `.claude/skills/playwright-cli/` and `.claude/skills/ux-designer/` are still standalone project skills, not installable marketplace plugins.

## Repository Layout

| File / Directory | Purpose |
| --- | --- |
| `.claude-plugin/marketplace.json` | Root marketplace catalog for remote `/plugin marketplace add` installs. |
| `CLAUDE.md` | Root context and team policy file (single source of truth). |
| `SOUL.md` | Shared behavioral defaults for all agents. |
| `dev-mode/` | Installable Claude plugin containing mode switching, hooks, agents, and core workflow skills. |
| `.claude/skills/playwright-cli/` | Optional browser automation skill, kept separate from the core workflow plugin. |
| `.claude/skills/ux-designer/` | Optional UI/UX skill, kept separate from the core workflow plugin. |

## Building and Packaging Plugins

There is no compile step for Claude plugins in this repo. "Build" means assembling a valid plugin directory, validating it locally, and listing it in the root marketplace catalog.

1. Create or update a plugin directory such as `dev-mode/`.
2. Ensure the plugin has a manifest at `.claude-plugin/plugin.json`.
3. Keep the plugin self-contained with its own `README.md`, and any `skills/`, `agents/`, `hooks/`, `bin/`, `.mcp.json`, or `.lsp.json` files it needs.
4. Bump the plugin version in its `plugin.json` when you ship a new release.
5. Add or update the plugin entry in the repo's root `.claude-plugin/marketplace.json` so remote users can discover and install it.
6. Test locally before publishing:

```bash
claude --plugin-dir ./dev-mode
```

Then, inside Claude Code, run:

```text
/reload-plugins
```

## Installing Plugins from This Repo

Remote users can install plugins from this repository through Claude Code's plugin manager.

### 1. Add this repo as a marketplace

```text
/plugin marketplace add drmaas/coding-agent-template
```

This uses the root `.claude-plugin/marketplace.json` file in the repo.

### 2. Install a plugin from the marketplace

```text
/plugin install dev-mode@coding-agent-template
```

### 3. Reload plugins in the current session

```text
/reload-plugins
```

After the marketplace is added, users can also browse plugins interactively through `/plugin`:

1. Open `/plugin`
2. Go to **Discover**
3. Choose `dev-mode`
4. Install it in the desired scope

## Publishing Notes

- **This repo marketplace** is the direct distribution path for remote users.
- **Official marketplace publishing** is optional and separate. If a plugin is later published to an external marketplace, users would install it with `/plugin install <plugin-name>@<marketplace-name>`.
- Marketplace-backed distribution is what makes `/plugin install` work for remote users; a plugin directory by itself is only enough for local development with `--plugin-dir`.
