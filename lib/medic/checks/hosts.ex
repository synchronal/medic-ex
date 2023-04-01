defmodule Medic.Checks.Hosts do
  @moduledoc "Host-related checks"

  @doc """
  Uses [hostess](https://github.com/cbednarski/hostess) to check that the given host exists in `/etc/hosts`,
  and if not, suggests using hostess to add the host pointing at `127.0.0.1`.

  Assumes that hostess is installed.

  Accepts a `remedy` option.

  ```
  {Medic.Checks.Hosts, :host_exists?, ["myapp.local"]}
  {Medic.Checks.Hosts, :host_exists?, ["myapp2.local", remedy: "sudo hostess add myapp2 127.0.0.2"]}
  ```
  """
  @spec host_exists?(binary(), keyword()) :: Medic.Check.check_return_t()
  def host_exists?(host, opts \\ []) do
    remedy = Keyword.get(opts, :remedy, "sudo hostess add #{host} 127.0.0.1")

    case System.cmd("hostess", ["has", host]) do
      {_output, 0} -> :ok
      {output, _} -> {:error, "expected “#{host}“ to exist: #{output}", remedy}
    end
  end
end
