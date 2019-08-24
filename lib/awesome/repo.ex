defmodule Awesome.Repo do
  use Ecto.Repo,
    otp_app: :awesome,
    adapter: Ecto.Adapters.Postgres
end
