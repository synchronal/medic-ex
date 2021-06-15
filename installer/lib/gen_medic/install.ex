defmodule GenMedic.Install do
  @moduledoc false
  use GenMedic.Generator

  template :support, [
    {:sh, "_support/cecho.sh", ".medic/_support/cecho.sh"},
    {:sh, "_support/check.sh", ".medic/_support/check.sh"},
    {:sh, "_support/confirm.sh", ".medic/_support/confirm.sh"},
    {:sh, "_support/doctor.sh", ".medic/_support/doctor.sh"},
    {:sh, "_support/os.sh", ".medic/_support/os.sh"},
    {:sh, "_support/step.sh", ".medic/_support/step.sh"}
  ]

  template :require, [
    {:eex, "require.exs", ".medic/require.exs"},
    {:text, "doctor.exs", ".medic/doctor.exs"},
    {:text, "update.exs", ".medic/update.exs"},
    {:dir, "checks", ".medic/checks"},
    {:dir, "skipped", ".medic/skipped"}
  ]

  template :bin, [
    {:sh, "bin/dev/docs", "bin/dev/docs"},
    {:sh, "bin/dev/doctor", "bin/dev/doctor"},
    {:sh, "bin/dev/start", "bin/dev/start"},
    {:sh, "bin/dev/test", "bin/dev/test"},
    {:sh, "bin/dev/update", "bin/dev/update"}
  ]

  template :file_mods, [
    {:mod, ".medic/skipped", ".gitignore"},
    {:mod, ".medic/.doctor.out", ".gitignore"}
  ]

  def generate(project) do
    copy_from(project, __MODULE__, :support)
    copy_from(project, __MODULE__, :require)
    copy_from(project, __MODULE__, :bin)
    copy_from(project, __MODULE__, :file_mods)
  end
end
