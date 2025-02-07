Mox.defmock(Medic.Cmd.MockSystemCmd, for: Medic.Cmd.SystemCmd)
Mox.defmock(Medic.MockSystem, for: Medic.System)
Application.put_env(:medic, :system_cmd, Medic.Cmd.MockSystemCmd)
Application.put_env(:medic, :system, Medic.MockSystem)

ExUnit.start()
