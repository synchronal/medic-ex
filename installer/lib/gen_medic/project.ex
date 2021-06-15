defmodule GenMedic.Project do
  @moduledoc false
  alias GenMedic.Project

  defstruct base_path: nil,
            binding: []

  def new(base_path) do
    __struct__(base_path: base_path)
  end

  def join(%Project{} = project, path) do
    project.base_path
    |> Path.join(path)
  end

  def put_bindings(%Project{} = project, vars) do
    %{project | binding: Keyword.merge(project.binding, vars)}
  end
end
