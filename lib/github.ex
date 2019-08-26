defmodule GitHubApi do
  @api_github "https://api.github.com"
  @headers [{'Authorization', 'token b103714d469792ff744671732cfb75215749044a'}]

  @spec fetch(MarkdownRepo.t(), String.t()) :: GitRepo.t() | :not_found
  def fetch(
        %MarkdownRepo{org: owner, name: repo, desc: desc, category: category},
        addr \\ @api_github
      ) do
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
