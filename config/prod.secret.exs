# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
use Mix.Config

config :awesome, Awesome.Repo,
  ssl: true,
  username: "postgres",
  password: "postgres",
  database: "awesome",
  hostname: "localhost",
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

config :awesome, AwesomeWeb.Endpoint,
  http: [:inet6, port: String.to_integer(System.get_env("PORT") || "4000")],
  server: true
