defmodule Http do
  @spec get(String.t(), [{String.t(), String.t()}]) :: String.t() | :not_found
  def get(url, headers \\ []) do
    case :hackney.request(:get, url, headers, "", follow_redirect: true) do
      {:ok, 200, _headers, ref} ->
        {:ok, body} = :hackney.body(ref)
        body

      {:ok, 404, _headers, _ref} ->
        :not_found
    end
  end
end
