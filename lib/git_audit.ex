defmodule GitAudit do
  @moduledoc """
  Documentation for `GitAudit`.
  """

  @doc """
  Walks directories and reports all top level that has a .git folder in it
  """
  def walk_directories(base_path) do
    if File.dir?(base_path) do
      found_paths = File.ls!(base_path)
      if Enum.member?(found_paths, ".git") and File.dir?(".git") do
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
    |> Enum.map(&check_path/1)
  end

  def print_report(path) do
    report(path)
    |> Enum.each(fn {status, path} ->
      IO.puts "(#{status}) #{path}"
    end)
  end
end
