import Config

config :registry_cleaner,
  registry_host: System.fetch_env!("REGISTRY_HOST"),
  proto: System.fetch_env!("PROTO"),
  tags: System.fetch_env!("TAGS") |> String.split(","),
  registry_username: System.fetch_env!("REGISTRY_USERNAME"),
  registry_password: System.fetch_env!("REGISTRY_PASSWORD"),
  max_per_tag: System.fetch_env!("MAX_PER_TAG") |> Integer.parse() |> elem(0),
  run_every: System.fetch_env!("RUN_EVERY") |> Integer.parse() |> elem(0)
