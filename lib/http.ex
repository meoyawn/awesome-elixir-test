defmodule Http do
  @spec get(String.t(), [{charlist, charlist}]) :: charlist | :not_found
  def get(url, headers \\ []) do
    plus_ua = [{'User-Agent', 'httpc'} | headers]

    case :httpc.request(:get, {to_charlist(url), plus_ua}, [], []) do
      {:ok, {{_ver, 200, _msg}, _headers, body}} -> body
      {:ok, {{_ver, 404, _msg}, _headers, _body}} -> :not_found
    end
  end
end
