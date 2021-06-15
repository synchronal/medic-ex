defmodule GenMedic.Generator do
  @moduledoc false
  import Mix.Generator
  alias GenMedic.Project

  @callback generate(Project.t()) :: Project.t()

  defmacro __using__(_env) do
    quote do
      @behaviour unquote(__MODULE__)
      import Mix.Generator
      import unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :templates, accumulate: true)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    root = Path.expand("../../templates", __DIR__)

    templates_ast =
      for {name, mappings} <- Module.get_attribute(env.module, :templates) do
        for {format, source, _} <- mappings, format != :dir do
          path = Path.join(root, source)

          case format do
            :eex ->
              compiled = EEx.compile_file(path)

              quote do
                @external_resource unquote(path)
                @file unquote(path)
                def render(unquote(name), unquote(source), var!(assigns))
                    when is_list(var!(assigns)),
                    do: unquote(compiled)
              end

            command when command in [:text, :sh] ->
              quote do
                @external_resource unquote(path)
                def render(unquote(name), unquote(source), _assigns),
                  do: unquote(File.read!(path))
              end

            _ ->
              nil
          end
        end
      end

    quote do
      unquote(templates_ast)
      def template_files(name), do: Keyword.fetch!(@templates, name)
    end
  end

  defmacro template(name, mappings) do
    quote do
      @templates {unquote(name), unquote(mappings)}
    end
  end

  def copy_from(project, mod, name) when is_atom(name) do
    mapping = mod.template_files(name)

    for {format, source, target_path} <- mapping do
      target = Project.join(project, target_path)

      case format do
        :dir ->
          create_directory(target)
          File.touch!(Path.join(target, ".gitkeep"))

        :eex ->
          contents = mod.render(name, source, project.binding)
          create_file(target, contents)

        :mod ->
          modify_file(target_path, target, source)

        :text ->
          create_file(target, mod.render(name, source, project.binding))

        :sh ->
          create_file(target, mod.render(name, source, project.binding))
          File.chmod!(target, 0o755)
      end
    end
  end

  def modify_file(relative_path, absolute_path, additions) when is_binary(additions) do
    log(:green, :modifying, "#{relative_path} -> #{additions}", [])

    with {:ok, path} <- file_exists?(absolute_path),
         {:ok, file_contents} <- File.read(path) do
      unless String.contains?(file_contents, additions) do
        File.write!(path, "\n#{additions}", [:append, :write])
      end
    else
      other -> raise "Unable to modify file: #{inspect(other)}"
    end
  end

  def file_exists?(path) do
    if File.exists?(path),
      do: {:ok, path},
      else: {:error, :noent}
  end

  defp log(color, command, message, opts) do
    unless opts[:quiet] do
      Mix.shell().info([color, "* #{command} ", :reset, message])
    end
  end
end
