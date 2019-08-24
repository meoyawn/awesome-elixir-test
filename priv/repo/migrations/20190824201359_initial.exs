defmodule Awesome.Repo.Migrations.Initial do
  use Ecto.Migration

  def up do
    execute """
    CREATE TABLE categories (
      name        TEXT PRIMARY KEY,
      description TEXT NOT NULL
    )
    """

    execute """
    CREATE TABLE repositories (
      owner       TEXT      NOT NULL,
      name        TEXT      NOT NULL,
      category    TEXT      NOT NULL REFERENCES categories(name),
      html_desc   TEXT      NOT NULL,
      stars       INTEGER   NOT NULL,
      last_commit TIMESTAMP NOT NULL,

      PRIMARY KEY(owner, name)
    )
    """
  end

  def down do
    execute "DROP TABLE repositories"
    execute "DROP TABLE categories"
  end
end
