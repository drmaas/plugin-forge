# plugin-forge

`plugin-forge` is a marketplace repository of installable Claude Code productivity plugins.

Use it when you want to improve developer workflow without rewriting repo instructions or custom prompts.

## Quick Start

```text
/plugin marketplace add drmaas/plugin-forge
/plugin install devmode@plugin-forge
/reload-plugins
```

Then choose a mode:

```text
/devmode:dm
```

## What This Repo Provides

This repository ships:

- a marketplace catalog at `.claude-plugin/marketplace.json`
- installable plugins listed in that catalog

### Available Plugins

| Plugin | Path | Purpose |
| --- | --- | --- |
| `devmode` | `devmode/` | Switch Claude execution style by mode (`og`, `tdd`, `vibe`, `poc`, `sdd`, `brainstorm`, `oneoff`). |

## Install from Marketplace

1. Add this repository as a marketplace:

```text
/plugin marketplace add drmaas/plugin-forge
```

2. Install a plugin:

```text
/plugin install <plugin-name>@plugin-forge
```

Example:

```text
/plugin install devmode@plugin-forge
```

3. Reload plugins in the current session:

```text
/reload-plugins
```

You can also browse interactively:

1. Run `/plugin`.
2. Open **Discover**.
3. Select `plugin-forge`.
4. Install the plugin in your desired scope.

## Use `devmode`

`devmode` controls how Claude executes work in the current session.

Core command:

```text
/devmode:dm
```

Useful direct commands:

```text
/devmode:dm status
/devmode:dm list
/devmode:dm set oneoff
```

Implementation-oriented modes route through builder and reviewer automatically. `brainstorm` mode stays non-coding.

For full mode-by-mode flow details, Ralph Loop (Ralph mode) behavior, and troubleshooting, see [devmode/README.md](./devmode/README.md).

## Local Development (Plugin Authors)

Each plugin should be self-contained in its own directory and include `.claude-plugin/plugin.json`.

When adding or updating a plugin in this repository:

1. Create or update the plugin directory.
2. Add or update plugin manifest and files.
3. Update `.claude-plugin/marketplace.json`.
4. Update that plugin's own README.

Run a local plugin directory directly:

```bash
claude --plugin-dir ./devmode
```

## Troubleshooting

- Plugin installed but behavior did not change: run `/reload-plugins`.
- Not sure which mode is active: run `/devmode:dm status`.
- Need full plugin behavior details: read [devmode/README.md](./devmode/README.md).

## References

- Marketplace catalog: [.claude-plugin/marketplace.json](./.claude-plugin/marketplace.json)
- `devmode` docs: [devmode/README.md](./devmode/README.md)
