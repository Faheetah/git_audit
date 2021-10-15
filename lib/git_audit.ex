defmodule GitAudit do
  @moduledoc """
  Documentation for `GitAudit`.
  """
  
  def main(params) do
    case OptionParser.parse!(params, strict: [ansi: :boolean]) do
      {args, [path | _]} ->
        ansi = Keyword.get(args, :ansi)
        GitAudit.print_report(path, ansi)

      _ -> IO.puts("Please specify a path: mix git_archive PATH")
    end
  end

  @doc """
  Walks directories and reports all top level that has a .git folder in it
  """
  def walk_directories(base_path) do
    if File.dir?(base_path) do
      found_paths = File.ls!(base_path)
      if Enum.member?(found_paths, ".git") and File.dir?(Path.join(base_path, ".git")) do
        [base_path]
      else
        Enum.flat_map(found_paths, fn dir -> walk_directories(Path.join(base_path, dir)) end)
      end
    else
      []
    end
  end

  def check_path(path) do
    cond do
      System.cmd("git", ~w[status --porcelain], cd: path) != {"", 0} -> {:dirty, path}
      System.cmd("git", ~w[log --branches --not --remotes --oneline], cd: path) != {"", 0} -> {:unpushed, path}
      true -> {:ok, path}
    end
  end

  def report(path) do
    walk_directories(path)
    |> Enum.sort()
    |> Enum.map(fn p ->
      Task.async(fn -> check_path(p) end)
    end)
    |> Task.await_many()
  end

  def print_report(path, ansi) do
    status_colors = %{ok: 32, unpushed: 33, dirty: 31}

    report(path)
    |> Enum.each(fn {status, path} ->
      if ansi || ansi == nil do
        IO.puts "\e[1;#{status_colors[status]}m(#{status}) #{path}\e[0m"
      else
        IO.puts "(#{status}) #{path}"
      end
    end)
  end
end
