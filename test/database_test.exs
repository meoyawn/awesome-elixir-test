defmodule DatabaseTest do
  use Awesome.DataCase, async: true

  test "empty database is empty" do
    assert Database.select_all() == []
  end

  test "one category two repos" do
    dt = DateTime.utc_now()

    repo1 = %GitRepo{
      owner: "o",
      repo: "r",
      category: "c",
      html_desc: "h",
      stars: 123,
      last_commit: dt
    }

    repo2 = %GitRepo{
      owner: "o2",
      repo: "r2",
      category: "c",
      html_desc: "h",
      stars: 1234,
      last_commit: dt
    }

    Database.insert_all([repo1, repo2], [%MarkdownCategory{name: "c", desc: "d"}])
    assert Database.select_all() == [%Category{desc: "d", name: "c", repos: [repo2, repo1]}]
  end
end
