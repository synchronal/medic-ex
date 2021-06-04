# Installation

Add the following file at `.medic/require.exs`:

```elixir
Mix.install([
  {:medic, force: true}
])
```

Add the following line to `.gitignore`:

```
.medic/skipped/
```

And the following files:

- `bin/dev/doctor`:

  ```bash
  #!/usr/bin/env bash

  set -e
  set -u
  set -o pipefail

  source "bin/dev/_support/doctor.sh"

  if [[ ! -f .doctor.skip ]]; then
    touch .doctor.skip
  fi

  # run doctor in home directory if present
  if [[ -f "${HOME}/bin/dev/doctor" ]]; then
    if ! step "Found a doctor script in home directory" "pushd ${HOME} > /dev/null && ./bin/dev/doctor && popd > /dev/null"; then
      exit 1
    fi
  fi

  cecho --green "\n▸" --bright-bold-cyan "Running initial doctor checks..."

  check "asdf: installed" \
    "command -v asdf" \
    "open 'https://asdf-vm.com/#/core-manage-asdf'"

  check "asdf: erlang plugin installed" \
    "asdf plugin-list | grep erlang" \
    "asdf plugin-add erlang"

  check "asdf: elixir plugin installed" \
    "asdf plugin-list | grep elixir" \
    "asdf plugin-add elixir"

  check "asdf: tools are installed" \
    "asdf which erl > /dev/null && asdf which elixir > /dev/null" \
    "asdf install"

  echo ""

  elixir -r .medic/require.exs -e "Medic.Doctor.run()" $*
  ```

- `bin/dev/test`:

  ```bash
  #!/bin/bash

  elixir -r .medic/require.exs -e "Medic.Test.run()" $*
  ```

- `bin/dev/update`:

  ```bash
  #!/usr/bin/env bash

  set -e

  trap "exit" INT

  elixir -r .medic/require.exs -e "Medic.Update.run()" $*
  ```

## Configure Doctor checks

Doctor defaults to a subset of available checks. The set of checks to run
can be configured in `.doctor.exs`. If this file exists, it should be a
list of check tuples.

For example:

```elixir
[
  {Medic.Checks.Homebrew, :bundled?},
  {Medic.Checks.Chromedriver, :unquarantined?},
  {Medic.Checks.Chromedriver, :versions_match?},
  {Medic.Checks.Direnv, :envrc_file_exists?},
  {Medic.Checks.Direnv, :has_all_keys?},
  {Medic.Checks.Asdf, :plugin_installed?, ["postgres"]},
  {Medic.Checks.Asdf, :package_installed?, ["postgres"]},
  {Medic.Checks.Hex, :local_hex_installed?},
  {Medic.Checks.Hex, :packages_installed?},
  {Medic.Checks.NPM, :exists?},
  {Medic.Checks.NPM, :require_minimum_version, ["7.8.0"]},
  {Medic.Checks.NPM, :any_packages_installed?},
  {Medic.Checks.NPM, :all_packages_installed?},
  {Medic.Checks.Postgres, :running?},
  {Medic.Checks.Postgres, :correct_version_running?},
  {Medic.Checks.Postgres, :role_exists?},
  {Medic.Checks.Postgres, :correct_data_directory?},
  {Medic.Checks.Postgres, :database_exists?, ["apex_dev"]}
]
```

## Configure Update commands

Commands are read from `.medic.update.exs` in your project, which should
contain a list of commands.

### Recommended Update configuration

This is the recommended list of commands for a database-backed Phoenix app (in this order):

```elixir
[:update_code, :update_mix, :update_npm, :build_npm, :migrate, :doctor]
```

When creating a new project, just copy the line above into `.medic.update.exs`
in your project.

### Built-in Update commands

The following commands are built in and can be specified as atoms:

- `update_code`: performs `git pull --rebase`
- `update_mix`: performs `mix deps.get`
- `update_npm`: performs `npm install --prefix assets`
- `build_npm`: performs `npm run build --prefix assets`
- `migrate`: performs `mix ecto.migrate`
- `doctor`: runs `Medic.Doctor`. Typically this is the last command you want to run.

### Custom Update commands

A custom command is a list with 3 or 4 items: a description, a shell command, arguments,
and an optional list of opts that will be sent to `System.cmd/3`.
For example: `["Seeding DB", "mix", ["run", "priv/repo/seeds.exs"]]`

Your `.medic.update.exs` file can have a combination of built-in commands and custom commands:

```elixir
[
  :update_code,
  :update_mix,
  :update_npm,
  :build_npm,
  :migrate,
  ["Seeding DB", "mix", ["run", "priv/repo/seeds.exs"]],
  :doctor
]
```

## Using medic from github

```elixir
Mix.install([
  {:medic, github: "geometerio/medic", force: true}
])
```

## Using medic from your local filesystem (when modifying medic)

```elixir
Mix.install([
  {:medic, path: Path.expand("../../medic", __DIR__), force: true}
])
```

(You may need to change the path to match your filesystem layout.)
