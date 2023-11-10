defmodule Medic.Checks.Corepack do
  @moduledoc """
  Corepack is a thing build into node to shim package managers.
  """

  def shim_installed?(shim) do
    with {:ok, _node_version} <- node_version(),
         {:ok, _corepack_version} <- corepack_version() do
      corepack_shim_installed?(shim)
    end
  end

  defp node_version do
    case System.cmd("node", ["-v"]) do
      {"v" <> node_version, 0} -> {:ok, String.trim(node_version)}
      {output, _exit} -> {:error, "Node version not found\n#{output}", "## install nodejs"}
    end
  end

  defp corepack_shim_installed?(shim) do
    [package, _version] = String.split(shim, "@")

    with {corepack_path, 0} <- System.cmd("which", ["corepack"]),
         {real_corepack_path, 0} <- System.cmd("realpath", [Path.join(String.trim(corepack_path), "../../shims")]) do
      if real_corepack_path |> String.trim() |> Path.join(package) |> File.exists?(),
        do: :ok,
        else: {:error, "Corepack #{shim} not found", "corepack enable && corepack prepare #{shim} --activate"}
    else
      _other ->
        {:error, "Corepack not found", "## install nodejs"}
    end
  end

  defp corepack_version do
    case System.cmd("corepack", ["-v"]) do
      {corepack_version, 0} -> {:ok, String.trim(corepack_version)}
      {output, _exit} -> {:error, "Corepack version not found\n#{output}", "## install nodejs"}
    end
  end
end
