# Medic

Medic is a tool for helping developers to set up a project on their workstation. It is optimized for MacOS, with
a number of assumptions built in.

* Homebrew for system dependencies
* ASDF for language dependencies

It ships with a set of checks and high-level runners.

## Runners

* `Medic.Doctor` - runs checks to make sure that a development workstation can
  run the application
* `Medic.Test` - runs the required set of tests to validate your application
* `Medic.Update` - all the things you want to do after (and including) git pull

## Checks

Checks are defined as modules and functions in the `Medic.Checks` namespace.

Checks are configured to run via `Medic.Doctor` via MFA 
(`{module, function, arguments}`) syntax, with `{module, function}` as a shortcut
for zero-arity checks.

