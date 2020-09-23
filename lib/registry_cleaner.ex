defmodule RegistryCleaner do
  alias HTTPoison
  alias Lib
  require Logger

  def headers do
    encoded = Base.encode64("#{Lib.env(:registry_username)}:#{Lib.env(:registry_password)}")
    [Authorization: "Basic #{encoded}"]
  end

  def main, do: get_images() |> Enum.map(&handle_image/1)

  def get_images do
    with %HTTPoison.Response{body: body, status_code: status_code} <-
           "#{Lib.url()}/_catalog" |> HTTPoison.get!(headers()),
         200 <- status_code do
      body |> Poison.decode!() |> Map.get("repositories") |> IO.inspect()
    else
      _ -> Logger.error("Could not get list tags for image ")
    end
  end

  # IMAGES=portfolio-server,portfolio-client
  def handle_image(image) do
    with %HTTPoison.Response{body: body, status_code: status_code} <-
           "#{Lib.url()}/#{image}/tags/list" |> HTTPoison.get!(headers()),
         200 <- status_code do
      tags = body |> Poison.decode!() |> Map.get("tags")

      Enum.map(Lib.env(:tags), fn base_tag ->
        filtered = sort_filter_tags(image, tags, base_tag)
        nr = delete_nr(length(filtered))

        filtered
        |> Enum.take(nr)
        |> Enum.map(fn {_, _, e} ->
          "#{Lib.url()}/#{image}/manifests/#{e}" |> HTTPoison.delete!(headers())
        end)

        Logger.log(:info, "Deleted #{nr} images named: '#{image}:#{base_tag}-*'")
      end)
    else
      _ -> Logger.error("Could not get list tags for image #{image}")
    end
  end

  def delete_nr(len) do
    case Lib.env(:max_per_tag) do
      n when n < len -> len - n
      _ -> 0
    end
  end

  def sort_filter_tags(image, tags, base_tag) do
    tags
    |> Enum.filter(fn t -> String.starts_with?(t, base_tag) end)
    |> Enum.map(fn t -> handle_tag(image, t) end)
    |> Enum.sort_by(fn {_, dt, _} -> dt end, DateTime)
  end

  def handle_tag(image, tag) do
    date = get_date(image, tag)
    digest = get_digest(image, tag)
    {tag, date, digest}
  end

  def get_date(image, tag) do
    "#{Lib.url()}/#{image}/manifests/#{tag}"
    |> HTTPoison.get!(headers())
    |> case do
      %HTTPoison.Response{body: body} ->
        body
        |> Poison.decode!()
        |> Map.get("history")
        |> List.first()
        |> Map.get("v1Compatibility")
        |> Poison.decode!()
        |> Map.get("created")
        |> DateTime.from_iso8601()
        |> elem(1)

      _ ->
        Logger.error("Could not get manifest for #{image}:#{tag}")
    end
  end

  def get_digest(image, tag) do
    "#{Lib.url()}/#{image}/manifests/#{tag}"
    |> HTTPoison.get!(
      [Accept: "application/vnd.docker.distribution.manifest.v2+json"] ++ headers()
    )
    |> case do
      %HTTPoison.Response{headers: headers} ->
        headers |> List.keyfind("Docker-Content-Digest", 0) |> elem(1)

      _ ->
        Logger.error("Could not get digest for #{image}:#{tag}")
    end
  end
end
