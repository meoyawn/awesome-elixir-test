defmodule MarkdownTest do
  use ExUnit.Case, async: true

  import FakeServer
  import FakeServer.Response

  test_with_server "not found" do
    assert_raise RuntimeError, fn ->
      Markdown.fetch(FakeServer.http_address())
    end
  end

  test_with_server "nonsense" do
    route("/h4cc/awesome-elixir/master/README.md", ok!("nonsense"))
    assert Markdown.fetch(FakeServer.http_address()) == {[], []}
  end

  test_with_server "success" do
    str = """
    ## Actors

    *Libraries and tools for working with actors and such.*

    * [dflow](https://github.com/dalmatinerdb/dflow) - Pipelined flow processing engine.

    ## Algorithms and Data structures

    *Libraries and implementations of algorithms and data structures.*

    * [array](https://github.com/takscape/elixir-array) - An Elixir wrapper library for Erlang's array.
    """

    expected =
      {[
         %MarkdownCategory{
           desc: "*Libraries and implementations of algorithms and data structures.*",
           name: "Algorithms and Data structures"
         },
         %MarkdownCategory{
           desc: "*Libraries and tools for working with actors and such.*",
           name: "Actors"
         }
       ],
       [
         %MarkdownRepo{
           category: "Actors",
           desc: "Pipelined flow processing engine.",
           name: "dflow",
           org: "dalmatinerdb"
         },
         %MarkdownRepo{
           category: "Algorithms and Data structures",
           desc: "An Elixir wrapper library for Erlang's array.",
           name: "elixir-array",
           org: "takscape"
         }
       ]}

    route("/h4cc/awesome-elixir/master/README.md", ok!(str))
    assert Markdown.fetch(FakeServer.http_address()) == expected
  end
end
