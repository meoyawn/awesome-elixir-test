defmodule Http do
  @spec get(String.t(), [{charlist, charlist}]) :: charlist | :not_found
  def get(url, headers \\ []) do
    case :httpc.request(:get, {to_charlist(url), headers}, [], []) do
      {:ok, {{_ver, 200, 'OK'}, _headers, body}} -> body
      {:ok, {{_ver, 404, 'OK'}, _headers, _body}} -> :not_found
    end
  end
end
