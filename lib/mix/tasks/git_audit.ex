defmodule Mix.Tasks.GitAudit do
  @moduledoc "Recursively check for dirty and unpushed subdirectories for a given path"

  use Mix.Task

  def run(params) do
    case OptionParser.parse!(params, strict: [ansi: :boolean]) do
      {args, [path | _]} ->
        ansi = Keyword.get(args, :ansi)
        GitAudit.print_report(path, ansi)

      _ -> IO.puts("Please specify a path: mix git_archive PATH")
    end
  end
end
