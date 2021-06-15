# GenMedic

Provides `gen.medic` installer as an archive.

## Installation from Hex

To install from Hex, run:

```shell
mix archive.install hex gen_medic
```

## Local installation

To build and install locally, first ensure any installed archives are removed:

```shell
cd installer
mix archive.uninstall gen_medic
MIX_ENV=prod mix do compile, archive.build, archive.install
```
