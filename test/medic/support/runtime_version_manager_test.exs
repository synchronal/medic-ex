defmodule Medic.Support.RuntimeVersionManagerTest do
  use ExUnit.Case
  import Mox

  setup :verify_on_exit!

  describe "current with asdf" do
    setup do
      stub(Medic.MockSystem, :find_executable, fn
        "asdf" -> "/usr/local/bin/asdf"
        "mise" -> nil
      end)

      :ok
    end

    test "returns the current version of a plugin from asdf 0.16+" do
      expect(Medic.Cmd.MockSystemCmd, :cmd, fn "asdf", ["current", "elixir"], [] ->
        {"""
         Name            Version         Source                  Installed
         elixir          1.18.2-thingy   /path/to/.tool-versions true
         """, 0}
      end)

      assert Medic.Support.RuntimeVersionManager.current("elixir") == {:ok, "1.18.2-thingy"}
    end

    test "returns the current version of a plugin from asdf 0.15 and older" do
      expect(Medic.Cmd.MockSystemCmd, :cmd, fn "asdf", ["current", "elixir"], [] ->
        {"""
         elixir          1.18.2-thingy   /path/to/.tool-versions true
         """, 0}
      end)

      assert Medic.Support.RuntimeVersionManager.current("elixir") == {:ok, "1.18.2-thingy"}
    end
  end

  describe "current with mise" do
    setup do
      stub(Medic.MockSystem, :find_executable, fn
        "asdf" -> nil
        "mise" -> "/usr/local/bin/mise"
      end)

      :ok
    end

    test "returns the current version" do
      expect(Medic.Cmd.MockSystemCmd, :cmd, fn "mise", ["current", "elixir"], [] ->
        {"""
         1.18.2-otp-yay
         """, 0}
      end)

      assert Medic.Support.RuntimeVersionManager.current("elixir") == {:ok, "1.18.2-otp-yay"}
    end
  end
end
