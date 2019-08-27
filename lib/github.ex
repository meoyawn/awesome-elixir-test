defmodule GitHubApi do
  @headers [{'Authorization', 'token 50048cabab30ba4d8ddf70cc511268ac264cade7'}]

  @spec host :: String.t()
  def host, do: "https://api.github.com"

  @spec fetch(MarkdownRepo.t(), String.t()) :: GitRepo.t() | :not_found
  def fetch(%MarkdownRepo{org: owner, name: repo, desc: desc, category: category}, addr) do
    case "#{addr}/repos/#{owner}/#{repo}" |> Http.get(@headers) do
      :not_found ->
        :not_found

      body ->
        %{"stargazers_count" => stars} = Jason.decode!(body)

        [%{"commit" => %{"author" => %{"date" => date}}}] =
          "#{addr}/repos/#{owner}/#{repo}/commits?per_page=1"
          |> Http.get(@headers)
          |> Jason.decode!()

        {:ok, dt, _offset} = DateTime.from_iso8601(date)

        %GitRepo{
          owner: owner,
          repo: repo,
          html_desc: desc |> Earmark.as_html!() |> String.slice(3..-6),
          category: category,
          stars: stars,
          last_commit: dt
        }
    end
  end
end
