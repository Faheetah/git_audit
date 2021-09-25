defmodule Mix.Tasks.GitAudit do
  use Mix.Task

  def run(params) do
    {args, [path | _]} = OptionParser.parse!(params, strict: [ansi: :boolean])

    ansi = Keyword.get(args, :ansi)
    GitAudit.print_report(path, ansi)
  end
end
