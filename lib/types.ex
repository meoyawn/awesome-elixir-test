defmodule MarkdownRepo do
  use TypedStruct

  typedstruct do
    field :org, String.t(), enforce: true
    field :name, String.t(), enforce: true
    field :desc, String.t(), enforce: true
    field :category, String.t(), enforce: true
  end
end

defmodule MarkdownCategory do
  use TypedStruct

  typedstruct do
    field :name, String.t(), enforce: true
    field :desc, String.t() | nil, enforce: true
  end
end

defmodule GitRepo do
  use TypedStruct

  typedstruct do
    field :owner, String.t(), enforce: true
    field :repo, String.t(), enforce: true
    field :html_desc, String.t(), enforce: true
    field :category, String.t(), enforce: true
    field :stars, non_neg_integer, enforce: true
    field :last_commit, DateTime.t(), enforce: true
  end
end

defmodule Category do
  use TypedStruct

  typedstruct do
    field :name, String.t(), enforce: true
    field :desc, String.t(), enforce: true
    field :repos, [GitRepo.t()], enforce: true
  end
end
