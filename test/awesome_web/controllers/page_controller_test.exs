defmodule AwesomeWeb.PageControllerTest do
  use AwesomeWeb.ConnCase

  test "empty db", %{conn: conn} do
    conn = get(conn, "/")

    expected =
      "<!DOCTYPE html>\n<html lang=\"en\">\n  <head>\n    <meta charset=\"utf-8\"/>\n    <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\"/>\n    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"/>\n    <title>Awesome Elixir</title>\n    <link rel=\"stylesheet\" href=\"https://unpkg.com/awsm.css/dist/awsm.min.css\">\n  </head>\n  <body>\n    <header>\n      <h1>Awesome Elixir</h1>\n      <nav>\n        <ul>\n          <li><a href=\"/\">All</a></li>\n          <li><a href=\"/?min_stars=10\">⩾10⭐️</a></li>\n          <li><a href=\"/?min_stars=50\">⩾50⭐️</a></li>\n          <li><a href=\"/?min_stars=100\">⩾100⭐️</a></li>\n          <li><a href=\"/?min_stars=500\">⩾500⭐️</a></li>\n          <li><a href=\"/?min_stars=1000\">⩾1000⭐️</a></li>\n          <li><a href=\"/?min_stars=5000\">⩾5000⭐️</a></li>\n        </ul>\n      </nav>\n    </header>\n    <main role=\"main\" class=\"container\">\n  <i>No results for 0 stars. Try the links above</i>\n    </main>\n    <footer>\n      Adel Nizamutdinov 2019\n    </footer>\n  </body>\n</html>\n"

    assert html_response(conn, 200) == expected
  end

  test "non empty db", %{conn: conn} do
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
    conn = get(conn, "/")

    expected =
      "<!DOCTYPE html>\n<html lang=\"en\">\n  <head>\n    <meta charset=\"utf-8\"/>\n    <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\"/>\n    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"/>\n    <title>Awesome Elixir</title>\n    <link rel=\"stylesheet\" href=\"https://unpkg.com/awsm.css/dist/awsm.min.css\">\n  </head>\n  <body>\n    <header>\n      <h1>Awesome Elixir</h1>\n      <nav>\n        <ul>\n          <li><a href=\"/\">All</a></li>\n          <li><a href=\"/?min_stars=10\">⩾10⭐️</a></li>\n          <li><a href=\"/?min_stars=50\">⩾50⭐️</a></li>\n          <li><a href=\"/?min_stars=100\">⩾100⭐️</a></li>\n          <li><a href=\"/?min_stars=500\">⩾500⭐️</a></li>\n          <li><a href=\"/?min_stars=1000\">⩾1000⭐️</a></li>\n          <li><a href=\"/?min_stars=5000\">⩾5000⭐️</a></li>\n        </ul>\n      </nav>\n    </header>\n    <main role=\"main\" class=\"container\">\n  <h2 id=\"c\">c</h2>\n<p>d</p>\n  <ul>\n      <li  ><a href=\"https://github.com/o2/r2\">r2</a> ⭐️1234 🗓0 — h</li>\n      <li  ><a href=\"https://github.com/o/r\">r</a> ⭐️123 🗓0 — h</li>\n  </ul>\n    </main>\n    <footer>\n      Adel Nizamutdinov 2019\n    </footer>\n  </body>\n</html>\n"

    assert html_response(conn, 200) == expected
  end

  test "min stars", %{conn: conn} do
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
    conn = get(conn, "/?min_stars=1234")

    expected =
      "<!DOCTYPE html>\n<html lang=\"en\">\n  <head>\n    <meta charset=\"utf-8\"/>\n    <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\"/>\n    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"/>\n    <title>Awesome Elixir</title>\n    <link rel=\"stylesheet\" href=\"https://unpkg.com/awsm.css/dist/awsm.min.css\">\n  </head>\n  <body>\n    <header>\n      <h1>Awesome Elixir</h1>\n      <nav>\n        <ul>\n          <li><a href=\"/\">All</a></li>\n          <li><a href=\"/?min_stars=10\">⩾10⭐️</a></li>\n          <li><a href=\"/?min_stars=50\">⩾50⭐️</a></li>\n          <li><a href=\"/?min_stars=100\">⩾100⭐️</a></li>\n          <li><a href=\"/?min_stars=500\">⩾500⭐️</a></li>\n          <li><a href=\"/?min_stars=1000\">⩾1000⭐️</a></li>\n          <li><a href=\"/?min_stars=5000\">⩾5000⭐️</a></li>\n        </ul>\n      </nav>\n    </header>\n    <main role=\"main\" class=\"container\">\n  <h2 id=\"c\">c</h2>\n<p>d</p>\n  <ul>\n      <li  ><a href=\"https://github.com/o2/r2\">r2</a> ⭐️1234 🗓0 — h</li>\n  </ul>\n    </main>\n    <footer>\n      Adel Nizamutdinov 2019\n    </footer>\n  </body>\n</html>\n"

    assert html_response(conn, 200) == expected
  end

  test "bad arg", %{conn: conn} do
    conn = get(conn, "/?min_stars=foo")

    expected =
      "<!DOCTYPE html>\n<html lang=\"en\">\n  <head>\n    <meta charset=\"utf-8\"/>\n    <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\"/>\n    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"/>\n    <title>Awesome Elixir</title>\n    <link rel=\"stylesheet\" href=\"https://unpkg.com/awsm.css/dist/awsm.min.css\">\n  </head>\n  <body>\n    <header>\n      <h1>Awesome Elixir</h1>\n      <nav>\n        <ul>\n          <li><a href=\"/\">All</a></li>\n          <li><a href=\"/?min_stars=10\">⩾10⭐️</a></li>\n          <li><a href=\"/?min_stars=50\">⩾50⭐️</a></li>\n          <li><a href=\"/?min_stars=100\">⩾100⭐️</a></li>\n          <li><a href=\"/?min_stars=500\">⩾500⭐️</a></li>\n          <li><a href=\"/?min_stars=1000\">⩾1000⭐️</a></li>\n          <li><a href=\"/?min_stars=5000\">⩾5000⭐️</a></li>\n        </ul>\n      </nav>\n    </header>\n    <main role=\"main\" class=\"container\">\n  <i>No results for foo stars. Try the links above</i>\n    </main>\n    <footer>\n      Adel Nizamutdinov 2019\n    </footer>\n  </body>\n</html>\n"

    assert html_response(conn, 400) == expected
  end
end
