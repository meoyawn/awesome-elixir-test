defmodule Database do
  @type query :: %{
          :num_rows => non_neg_integer,
          :rows => nil | [binary | [any]],
          optional(atom) => any
        }

  @spec insert_cat(MarkdownCategory.t()) :: query
  defp insert_cat(%MarkdownCategory{name: name, desc: desc}) do
    """
    INSERT INTO categories (name, description)
    VALUES ($1, $2)
    """
    |> Awesome.Repo.query!([name, desc])
  end

  @spec insert_repo(GitRepo.t()) :: query
  defp insert_repo(%GitRepo{
         owner: owner,
         repo: name,
         category: cat,
         html_desc: html_desc,
         stars: stars,
         last_commit: last_commit
       }) do
    """
    INSERT INTO repositories (owner, name, category, html_desc, stars, last_commit)
    VALUES ($1, $2, $3, $4, $5, $6)
    """
    |> Awesome.Repo.query!([owner, name, cat, html_desc, stars, last_commit])
  end

  @spec insert_all([GitRepo.t()], [MarkdownCategory.t()]) :: any
  def insert_all(repos, cats) do
    Awesome.Repo.transaction(fn ->
      _ = Awesome.Repo.query!("TRUNCATE repositories, categories")
      Enum.each(cats, &insert_cat/1)
      Enum.each(repos, &insert_repo/1)
    end)
  end

  @spec select_all(non_neg_integer) :: [Category.t()]
  def select_all(min_stars \\ 0) do
    """
    SELECT r.owner, r.name, r.category, r.html_desc, r.stars, r.last_commit, c.description as cat_desc
    FROM repositories r
    JOIN categories c ON c.name = r.category
    WHERE r.stars >= $1
    ORDER BY r.category DESC, r.stars
    """
    |> Awesome.Repo.query!([min_stars])
    |> Map.get(:rows)
    |> Enum.reduce([], fn row, cats ->
      [owner, name, cat_name, html_desc, stars, last_commit, cat_desc] = row

      repo = %GitRepo{
        owner: owner,
        repo: name,
        category: cat_name,
        html_desc: html_desc,
        stars: stars,
        last_commit: DateTime.from_naive!(last_commit, "Etc/UTC")
      }

      last_cat_name =
        case cats do
          [%Category{name: name} | _] -> name
          _ -> :empty_list
        end

      if last_cat_name == cat_name do
        [head | tail] = cats
        [%{head | repos: [repo | head.repos]} | tail]
      else
        [%Category{name: cat_name, desc: cat_desc, repos: [repo]} | cats]
      end
    end)
  end
end
