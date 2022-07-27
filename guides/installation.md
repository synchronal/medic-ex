# Installation

Use the generators to add support files and set up your `.medic` directory:

```shell
mix archive.install hex gen_medic
mix gen.medic
```

## Installed Files

The medic generators will add a number of files in the root path of the current project:

```
├── .medic/
│   ├── .medic/require.exs
│   ├── .medic/doctor.exs
│   ├── .medic/update.exs
│   ├── .medic/_support/
│   │   ├── cecho.sh
│   │   ├── check.sh
│   │   ├── confirm.sh
│   │   ├── doctor.sh
│   │   ├── os.sh
│   │   └── step.sh
│   └── .medic/checks/
└── bin/dev/
    ├── docs
    ├── doctor
    ├── start
    ├── test
    └── update
```

And the following lines to `.gitignore`:

```
.medic/skipped/
.medic/.doctor.out
```

The shell scripts in `bin/dev` use the bash helpers in `.medic/_support` to help bootstrap a project
on a new computer (which may not have Erlang or Elixir, for instance). As quickly as possible, the
execution runtime moves into Elixir.

## Alternate Medic Source

Scripts in `bin/dev` require `.medic/require.exs`, which uses `Mix.install/1` to download Medic and
make it available. By default, `gen_medic` generates a file that looks like this, where version is
matched to version of `gen_medic`:

```elixir
Mix.install([
  {:medic, "~> 0.5.0", force: true}
])
```

To use medic from GitHub, change `.medic/require.exs` as follows:

```elixir
Mix.install([
  {:medic, github: "synchronal/medic", force: true}
])
```

When developing locally, a local path can be used:

```elixir
Mix.install([
  {:medic, path: "../../medic", force: true}
])
```

**Note:** In Elixir 1.12.0, relative paths must be expanded using `Path.expand(path, __DIR__)`.

## Configure Doctor Checks

Doctor defaults to a subset of available checks. The set of checks to run can be configured in
`.medic/doctor.exs`. If this file exists, it should be a list of check tuples.

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

## Configure Update Commands

Commands are read from `.medic/update.exs` in your project, which should contain a list of commands.

### Recommended Update Configuration

This is the recommended list of commands for a database-backed Phoenix app (in this order):

```elixir
[
  :update_code,
  :update_mix,
  :update_npm,
  :build_npm,
  :migrate,
  :doctor
]
```

When creating a new project, just copy the line above into `.medic/update.exs` in your project.

### Built-in Update Commands

The following commands are built in and can be specified as atoms:

- `update_code`: performs `git pull --rebase`
- `update_mix`: performs `mix deps.get`
- `update_npm`: performs `npm install --prefix assets`
- `build_npm`: performs `npm run build --prefix assets`
- `migrate`: performs `mix ecto.migrate`
- `doctor`: runs `Medic.Doctor`. Typically this is the last command you want to run.

### Custom Update Commands

A custom command is a list with 3 or 4 items: a description, a shell command, arguments, and an
optional list of opts that will be sent to `System.cmd/3`. For example:

`["Seeding DB", "mix", ["run", "priv/repo/seeds.exs"]]`

Your `.medic/update.exs` file can have a combination of built-in commands and custom commands:

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
