[
  {Medic.Checks.Homebrew, :bundled?},
  # {Medic.Checks.Git, :uses_ssh?, ["github.com"]},
  # {Medic.Checks.Chromedriver, :chrome_installed??},
  # {Medic.Checks.Chromedriver, :unquarantined?},
  # {Medic.Checks.Chromedriver, :versions_match?},
  # {Medic.Checks.Direnv, :envrc_file_exists?},
  # {Medic.Checks.Direnv, :has_all_keys?},
  {Medic.Checks.ToolVersions, :plugin_installed?, ["postgres"]},
  {Medic.Checks.ToolVersions, :package_installed?, ["postgres"]},
  {Medic.Checks.Hex, :local_hex_installed?},
  {Medic.Checks.Hex, :local_rebar_installed?},
  {Medic.Checks.Hex, :packages_installed?},
  {Medic.Checks.NPM, :exists?},
  {Medic.Checks.NPM, :require_minimum_version, ["7.16.0"]},
  {Medic.Checks.NPM, :any_packages_installed?},
  {Medic.Checks.NPM, :all_packages_installed?}
  # {Medic.Checks.Postgres, :running?},
  # {Medic.Checks.Postgres, :correct_version_running?},
  # {Medic.Checks.Postgres, :role_exists?},
  # {Medic.Checks.Postgres, :correct_data_directory?},
  # {Medic.Checks.Postgres, :database_exists?, ["my_app_dev"]}
]
