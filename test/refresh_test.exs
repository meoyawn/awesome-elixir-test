defmodule RefreshTest do
  use Awesome.DataCase, async: true

  import FakeServer
  import FakeServer.Response

  test_with_server "readme not found" do
    addr = http_address()

    assert_raise RuntimeError, fn ->
      PeriodicRefresh.refresh(addr, addr)
    end
  end

  @markdown """
  ## Actors

  *Libraries and tools for working with actors and such.*

  * [bar](https://github.com/foo/bar) - Pipelined flow processing engine.
  """

  test_with_server "md found, repo not found" do
    addr = http_address()
    route("/h4cc/awesome-elixir/master/README.md", ok!(@markdown))
    PeriodicRefresh.refresh(addr, addr)
    assert Database.select_all() == []
  end

  test_with_server "everything found" do
    addr = http_address()

    dt = DateTime.utc_now()
    dt_str = DateTime.to_iso8601(dt)

    route("/h4cc/awesome-elixir/master/README.md", ok!(@markdown))
    route("/repos/foo/bar", ok!(~s({"stargazers_count": 500})))
    route("/repos/foo/bar/commits", ok!(~s([{"commit": {"author": {"date": "#{dt_str}"}}}])))

    PeriodicRefresh.refresh(addr, addr)

    expected = [
      %Category{
        desc: "*Libraries and tools for working with actors and such.*",
        name: "Actors",
        repos: [
          %GitRepo{
            category: "Actors",
            html_desc: "Pipelined flow processing engine.",
            last_commit: dt,
            owner: "foo",
            repo: "bar",
            stars: 500
          }
        ]
      }
    ]

    assert Database.select_all() == expected
  end
end
