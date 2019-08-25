import Config

config :awesome, Awesome.Repo,
  username: "postgres",
  url: System.get_env("DATABASE_URL") || raise("env.DATABASE_URL not set"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

config :awesome, AwesomeWeb.Endpoint,
  http: [port: String.to_integer(System.get_env("PORT") || "4000"), compress: true],
  server: true
