# genv

A focused GitHub CLI wrapper for managing a repo's variables and secrets.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/tinloof/genv/main/install.sh | sh
```

This downloads `genv` into `~/.local/bin` (override with `GENV_BIN_DIR`). If that
directory isn't on your `PATH`, the installer tells you the line to add.

**Requirements:** the [GitHub CLI](https://cli.github.com) (`gh`), authenticated via
`gh auth login`, and a `bash` shell. On Windows that means **Git Bash or WSL** —
`genv` is a bash script and won't run in native PowerShell/cmd.

## Usage

```sh
genv <command> [options]
```

| Command | What it does |
| --- | --- |
| `genv pull [-e <env>] [-f <file>]` | Write GitHub **variables** → dotenv file (default `.env`) |
| `genv push [-e <env>] [-f <file>]` | Set GitHub **variables** from a dotenv file |
| `genv var <NAME> [value] [-e <env>]` | Set a single **variable** (value via stdin if omitted) |
| `genv secret <NAME> [value] [--fallback <v>] [-e <env>]` | Set a **secret**, with an optional same-named fallback variable |

- No `-e` targets **repository-level** config; `-e <name>` targets an **environment** (e.g. `production`), which is **created automatically** if it doesn't exist.
- **Secrets are write-only.** Pair a secret with a `--fallback` variable and resolve it in a workflow as `${{ secrets.NAME || vars.NAME }}`.
- Omit a secret/variable value to read it from **stdin** (keeps secrets out of shell history): `printf '%s' "$TOKEN" | genv secret API_KEY -e production`.
- `genv --help` and `genv <command> --help` document everything.

### Examples

```sh
genv pull -e production                                   # production variables → .env
genv push -e staging -f .env.stg                          # .env.stg → staging variables
genv var LOG_LEVEL debug -e production                    # one variable, in an environment
genv secret API_KEY --fallback sk-dummy -e production     # secret (value via stdin) + fallback
```

## Update / Uninstall

Re-run the install command to update. To uninstall:

```sh
rm "$(command -v genv)"
```
