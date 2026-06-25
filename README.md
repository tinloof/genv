# genv

GitHub Actions variables & secrets from the CLI — a small `gh` wrapper.

## Install

```sh
curl -fsSL https://genv.tinloof.com/install.sh | sh
```

Requires the [GitHub CLI](https://cli.github.com) (`gh`), authenticated (`gh auth login`),
and a `bash` shell (on Windows: Git Bash or WSL).

## Usage

```sh
genv list   [-e <env>] [--full]                          # list variables & secrets in one table
genv pull   [-e <env>] [-f <file>]                       # variables → dotenv file (default .env)
genv push   [-e <env>] [-f <file>]                       # dotenv file → variables
genv var    <NAME> [value] [-e <env>]                    # set one variable
genv secret <NAME> [value] [--fallback <v>] [-e <env>]   # set a secret (+ optional fallback variable)
```

No `-e` targets repo-level config; `-e <name>` targets an environment (created if missing).
Run `genv --help` for details.
