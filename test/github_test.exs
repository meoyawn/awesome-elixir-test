defmodule GitHubApiTest do
  use ExUnit.Case, async: true

  import FakeServer
  import FakeServer.Response

  test_with_server "returns :not_found when first hit is 404" do
    res =
      GitHubApi.fetch(
        %MarkdownRepo{org: "foo", name: "bar", category: "", desc: ""},
        FakeServer.http_address()
      )

    assert res == :not_found
  end

  test_with_server "crash when first is ok and second is 404" do
    route("/repos/foo/bar", ok!(~s({"stargazers_count": 500})))
    route("/repos/foo/bar/commits", not_found!())

    assert_raise ArgumentError, fn ->
      GitHubApi.fetch(
        %MarkdownRepo{org: "foo", name: "bar", category: "", desc: ""},
        FakeServer.http_address()
      )
    end
  end

  test_with_server "ok when both ok" do
    dt = DateTime.utc_now()
    dt_str = DateTime.to_iso8601(dt)

    route("/repos/foo/bar", ok!(~s({"stargazers_count": 500})))

    route(
      "/repos/foo/bar/commits",
      ok!(~s([{"commit": {"author": {"date": "#{dt_str}"}}}]))
    )

    act =
      GitHubApi.fetch(
        %MarkdownRepo{org: "foo", name: "bar", category: "", desc: ""},
        FakeServer.http_address()
      )

    exp = %GitRepo{
      owner: "foo",
      repo: "bar",
      category: "",
      html_desc: "",
      stars: 500,
      last_commit: dt
    }

    assert act == exp
  end

  test_with_server "rate limit exceeded" do
    route("/repos/foo/bar", forbidden!("some nonsense"))

    assert_raise CaseClauseError, fn ->
      GitHubApi.fetch(
        %MarkdownRepo{org: "foo", name: "bar", category: "", desc: ""},
        FakeServer.http_address()
      )
    end
  end
end
