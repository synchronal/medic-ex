defmodule Medic.Checks.Git do
  @moduledoc """
  Common checks for git configuration

  ## Examples

      {Check.Git, :uses_ssh?, ["github.com"]}
  """

  @doc """
  Checks to make sure that git defaults to using SSH instead of HTTPS.
  """
  @spec uses_ssh?(binary()) :: Medic.Check.check_return_t()
  def uses_ssh?(domain) when is_binary(domain) do
    case System.cmd("git", ["config", "-l"]) do
      {output, 0} ->
        if output =~ "url.ssh://git@#{domain}/.insteadof=https://#{domain}/" do
          :ok
        else
          {
            :error,
            "git may use https instead of ssh for domain #{domain}",
            "git config --global url.ssh://git@#{domain}/.insteadOf https://#{domain}/"
          }
        end

      {output, exit_status} ->
        {
          :error,
          "git returned exit status #{exit_status} when checking config:\n#{output}",
          "# install git"
        }
    end
  end
end
