# Installation

Add the following file at `.medic/require.exs`:

```elixir
Mix.install([
  {:medic, github: "geometerio/medic", force: true}
])
```

And the following files:

* `bin/dev/doctor`:
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
* `bin/dev/test`:
  ```bash
  #!/bin/bash

  elixir -r .medic/require.exs -e "Medic.Test.run()" $*
  ```
* `bin/dev/update`:
  ```bash
  #!/usr/bin/env bash

  set -e

  trap "exit" INT

  elixir -r .medic/require.exs -e "Medic.Update.run()" $*
  ```

## Configure checks

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
