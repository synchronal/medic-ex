defmodule Medic.Checks.Corepack do
  @moduledoc """
  Corepack is a thing build into node to shim package managers.
  """

  def shim_installed?(shim) do
    with {:ok, node_version} <- node_version(),
         :ok <- corepack_shim_installed?(node_version, shim) do
      global_package_installed?(shim)
    end
  end

  defp node_version do
    case System.cmd("node", ["-v"]) do
      {"v" <> node_version, 0} -> {:ok, String.trim(node_version)}
      {output, _exit} -> {:error, "Node version not found\n#{output}", "asdf install"}
    end
  end

  defp corepack_shim_installed?(node_version, shim) do
    home = System.fetch_env!("HOME")
    [package, _version] = String.split(shim, "@")

    home
    |> Path.join([
      ".asdf/installs/nodejs/",
      node_version,
      "/lib/node_modules/corepack/shims/",
      package
    ])
    |> File.exists?()
    |> if(
      do: :ok,
      else: {:error, "Corepack #{shim} not found", "corepack enable && corepack prepare #{shim} --activate"}
    )
  end

  defp global_package_installed?(shim) do
    [package, _version] = String.split(shim, "@")

    case System.cmd("npm", ["ls", "-g", package]) do
      {output, 0} ->
        if String.contains?(output, shim),
          do: :ok,
          else: {:error, "NPM shim #{shim} not found", "npm install -g #{shim}"}

      {_error, _exit_code} ->
        {:error, "NPM shim #{shim} not found", "npm install -g #{shim}"}
    end
  end
end
