defmodule Mix.Tasks.GitAudit do
  @moduledoc """
  Recursively traverses directories and determines if the directory has a .git subdirectory, then checks whether 
  the repo is dirty or if there are any unpushed commits. The script will stop traversing when a directory 
  contains a .git directory, to avoid unnecessarily recursing into vendored dependencies. Helpful to audit a 
  local development environment for work that has not been pushed.

  Run the git_audit task with a path. That's it. It will recursively audit the path.

  mix git_audit PATH

  For no colors, use the --no-ansi flag, i.e.

  mix get_audit PATH --no-ansi
  
  The following commands are ran on each git directory to determine the status:
  
  dirty: git status --porcelain
  
  unpushed: git log --branches --not --remotes --oneline
  
  If no condition matches, the directory is marked as ok
  
  """

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
