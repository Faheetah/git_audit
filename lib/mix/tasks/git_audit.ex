defmodule Mix.Tasks.GitAudit do
  @moduledoc "Recursively check for dirty and unpushed subdirectories for a given path"

  use Mix.Task

  def run(params) do
    {args, [path | _]} = OptionParser.parse!(params, strict: [ansi: :boolean])

    ansi = Keyword.get(args, :ansi)
    GitAudit.print_report(path, ansi)
  end
end
