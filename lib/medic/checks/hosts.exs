defmodule Medic.Checks.Hosts do
  def host_exists?(host) do
    case System.cmd("hostess", ["has", host]) do
      {_output, 0} -> :ok
      {output, _} -> {:error, "expected “#{host}“ to exist: #{output}", "sudo hostess add #{host} 127.0.0.1"}
    end
  end
end
