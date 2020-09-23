defmodule Lib do
  def env(name), do: Application.get_env(:registry_cleaner, name)

  def url, do: Lib.env(:proto) <> "://" <> Lib.env(:registry_host) <> "/v2"
end
