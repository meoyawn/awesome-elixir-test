defmodule Markdown do
  alias Earmark.Block

  @spec parse(String.t(), String.t()) :: MarkdownRepo.t() | :invalid
  defp parse(cat, str) do
    regex = ~r"\[.*\]\((.*)\) - (.*)"
    [_, url, desc] = Regex.run(regex, str)

    case URI.parse(url).path do
      path when path in [nil, "", "/"] ->
        :invalid

      path ->
        [org, name] = path |> String.split("/", trim: true) |> Enum.take(2)
        %MarkdownRepo{org: org, name: name, desc: desc, category: cat}
    end
  end

  @spec nesting_level?(integer, Block.t()) :: boolean
  defp nesting_level?(level, %Block.Heading{level: lvl}), do: lvl == level
  defp nesting_level?(_, _), do: true

  @spec reductor(Block.t(), {[MarkdownCategory.t()], [MarkdownRepo.t()]}) ::
          {[MarkdownCategory.t()], [MarkdownRepo.t()]}
  defp reductor(%Block.Heading{level: 2, content: heading}, {cats, repos}) do
    {[%MarkdownCategory{name: heading, desc: nil} | cats], repos}
  end

  defp reductor(%Block.Para{lines: [cat_desc]}, {cats, repos}) do
    [head | tail] = cats
    nostars = String.slice(cat_desc, 1..-2)
    {[%{head | desc: nostars} | tail], repos}
  end

  defp reductor(%Block.List{blocks: blocks}, {cats, repos}) do
    added =
      Enum.flat_map(blocks, fn b ->
        [%Block.Para{lines: [repo_str]}] = b.blocks

        case parse(hd(cats).name, repo_str) do
          :invalid -> []
          x -> [x]
        end
      end)

    {cats, repos ++ added}
  end

  @spec to_repos([Block.t()]) :: {[MarkdownCategory.t()], [MarkdownRepo.t()]}
  defp to_repos(blocks) do
    blocks
    |> Enum.drop_while(&nesting_level?(1, &1))
    |> Enum.take_while(&nesting_level?(2, &1))
    |> Enum.reduce({[], []}, &reductor/2)
  end

  @spec fetch :: {[MarkdownCategory.t()], [MarkdownRepo.t()]}
  def fetch do
    "https://raw.githubusercontent.com/h4cc/awesome-elixir/master/README.md"
    |> Http.get()
    |> Earmark.Parser.parse_markdown()
    |> elem(0)
    |> to_repos
  end
end
