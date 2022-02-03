Mox.defmock(Medic.Cmd.MockSystemCmd, for: Medic.Cmd.SystemCmd)
Application.put_env(:medic, :system_cmd, Medic.Cmd.MockSystemCmd)

ExUnit.start()
