defmodule Medic.Checks.NpmTest do
  use ExUnit.Case
  import Mox

  setup :verify_on_exit!

  describe "all_packages_installed?" do
    @failure_output """
    assets@ /foo/bar/assets
    ├── UNMET DEPENDENCY @sentry/browser@^6.13.2
    └── UNMET DEPENDENCY @sentry/tracing@^6.13.2

    npm ERR! code ELSPROBLEMS
    npm ERR! missing: @sentry/browser@^6.13.2, required by assets@
    npm ERR! missing: @sentry/tracing@^6.13.2, required by assets@
    """

    test "fails when npm reports unmet dependencies with a nonzero exit status" do
      expect(
        Medic.Cmd.MockSystemCmd,
        :cmd,
        fn "npm", ["ls", "--prefix", "assets", "--prefer-offline"], stderr_to_stdout: true ->
          {@failure_output, 1}
        end
      )

      assert Medic.Checks.NPM.all_packages_installed?() == {:error, String.trim(@failure_output), "npm ci --prefix assets"}
    end

    test "fails when npm reports unmet dependencies with a zero exit status" do
      expect(
        Medic.Cmd.MockSystemCmd,
        :cmd,
        fn "npm", ["ls", "--prefix", "assets", "--prefer-offline"], stderr_to_stdout: true ->
          {@failure_output, 0}
        end
      )

      assert Medic.Checks.NPM.all_packages_installed?() == {:error, String.trim(@failure_output), "npm ci --prefix assets"}
    end

    test "honors the `cd` option in both the check and the remedy with a nonzero exit status" do
      expect(
        Medic.Cmd.MockSystemCmd,
        :cmd,
        fn "npm", ["ls", "--prefix", "assets", "--prefer-offline"], cd: "server", stderr_to_stdout: true ->
          {@failure_output, 1}
        end
      )

      assert Medic.Checks.NPM.all_packages_installed?(cd: "server") == {:error, String.trim(@failure_output), "(cd server && npm ci --prefix assets)"}
    end

    test "honors the `cd` option in both the check and the remedy with a zero exit status" do
      expect(
        Medic.Cmd.MockSystemCmd,
        :cmd,
        fn "npm", ["ls", "--prefix", "assets", "--prefer-offline"], cd: "server", stderr_to_stdout: true ->
          {@failure_output, 0}
        end
      )

      assert Medic.Checks.NPM.all_packages_installed?(cd: "server") == {:error, String.trim(@failure_output), "(cd server && npm ci --prefix assets)"}
    end
  end

  describe "any_packages_installed?" do
    @failure_output """
    assets@ /foo/bar/assets
    ├── UNMET DEPENDENCY @sentry/browser@^6.13.2
    └── UNMET DEPENDENCY @sentry/tracing@^6.13.2

    npm ERR! code ELSPROBLEMS
    npm ERR! missing: @sentry/browser@^6.13.2, required by assets@
    npm ERR! missing: @sentry/tracing@^6.13.2, required by assets@
    """

    test "fails when npm reports unmet dependencies with a nonzero exit status" do
      expect(
        Medic.Cmd.MockSystemCmd,
        :cmd,
        fn "npm", ["list", "--prefix", "assets", "--dev"], [] ->
          {@failure_output, 1}
        end
      )

      assert Medic.Checks.NPM.any_packages_installed?() == {:error, String.trim(@failure_output), "npm ci --prefix assets"}
    end

    test "honors the `cd` option in both the check and the remedy with a nonzero exit status" do
      expect(
        Medic.Cmd.MockSystemCmd,
        :cmd,
        fn "npm", ["list", "--prefix", "assets", "--dev"], cd: "server" ->
          {@failure_output, 1}
        end
      )

      assert Medic.Checks.NPM.any_packages_installed?(cd: "server") == {:error, String.trim(@failure_output), "(cd server && npm ci --prefix assets)"}
    end
  end
end
