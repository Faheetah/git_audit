defmodule Mix.Tasks.GitAudit do
  use Mix.Task

  def run([path | _]) do
    GitAudit.print_report(path)
  end

  def run(_) do
    IO.puts "Usage: mix git_audit PATH"
  end
end
