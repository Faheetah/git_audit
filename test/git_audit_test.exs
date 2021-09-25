defmodule GitauditTest do
  use ExUnit.Case
  @origin_repo "test/repos/origin"
  @clone_repos ~w[clean dirty unpushed subdir/clean subdir/dirty subdir/unpushed]

  setup_all do
    File.mkdir_p!("false/positive")

    File.rm_rf!("test/repos")
    File.mkdir_p!(@origin_repo)
    File.write!("#{@origin_repo}/.gitignore", "/nested/")
    System.cmd("git", ["init"], cd: @origin_repo)
    System.cmd("git", ["add", ".gitignore"], cd: @origin_repo)
    System.cmd("git", ["commit", "-m", "original"], cd: @origin_repo)

    @clone_repos ++ ["clean/nested"]
    |> Enum.each(fn repo ->
      System.cmd("git", ["clone", @origin_repo, "test/repos/#{repo}"])
      if repo =~ "dirty" or repo =~ "unpushed" do
        File.write!("test/repos/#{repo}/added", "added")
      end

      if repo =~ "unpushed" do
        System.cmd("git", ["add", "added"], cd: "test/repos/#{repo}")
        System.cmd("git", ["commit", "-m", "added"], cd: "test/repos/#{repo}")
      end
    end)
  end

  test "walks directories and returns top level git directories" do
    found = Enum.sort(GitAudit.walk_directories("test/repos"))
    expected = Enum.sort(Enum.map(@clone_repos, &(Path.join("test/repos", &1))) ++ ["test/repos/origin"])
    assert found == expected
  end

  describe "checking paths" do
    test "with dirty repo" do
      assert GitAudit.check_path("test/repos/dirty") == {:dirty, "test/repos/dirty"}
    end

    test "with unpushed repo" do
      assert GitAudit.check_path("test/repos/unpushed") == {:unpushed, "test/repos/unpushed"}
    end

    test "with clean repo" do
      assert GitAudit.check_path("test/repos/unpushed") == {:unpushed, "test/repos/unpushed"}
    end
  end

  test "generates a report of all dirty and unpusehd repos" do
    found = Enum.sort(GitAudit.report("test/repos"))
    expected = [
      {:dirty, "test/repos/dirty"},
      {:dirty, "test/repos/subdir/dirty"},
      {:ok, "test/repos/clean"},
      {:ok, "test/repos/subdir/clean"},
      {:unpushed, "test/repos/origin"},
      {:unpushed, "test/repos/subdir/unpushed"},
      {:unpushed, "test/repos/unpushed"}
    ]
    assert found == expected
  end
end
