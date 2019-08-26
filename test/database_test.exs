defmodule DatabaseTest do
  use Awesome.DataCase, async: true

  test "lol" do
    assert Database.select_all() == []
  end
end
