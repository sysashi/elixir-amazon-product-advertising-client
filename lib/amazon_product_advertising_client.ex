defmodule AmazonProductAdvertisingClient do
  @moduledoc """
  An Amazon Product Advertising API client for Elixir
  """

  use HTTPoison.Base
  use Timex

  alias AmazonProductAdvertisingClient.Config

  @scheme "http"
  @host    Application.get_env(:amazon_product_advertising_client, :marketplace_host, "webservices.amazon.com")
  @path   "/onca/xml"

  @doc """
  Make a call to the API with the specified request parameters.
  """
  def call_api(request_params, config \\ %Config{}) do
    {secret, config} = Map.pop(config, :aws_secret_access_key)
    query = build_query([request_params, config])
    %URI{scheme: @scheme, host: @host, path: @path, query: query}
    |> build_url(secret)
    |> get()
  end

  defp build_query(params_list) do
    params_list
    |> to_map
    |> remove_empty
    |> combine_params
    |> percent_encode_query
  end

  defp to_map(params_list), do: Enum.map(params_list, &Map.from_struct/1)

  defp remove_empty(params_list) do
    Enum.map(params_list, fn params ->
      params
      |> Enum.reject(fn {_, v} -> is_nil(v) end)
      |> Enum.into(%{})
    end)
  end

  defp combine_params(params_list) do
    List.foldl params_list, Map.new, fn(params, all_params) ->
      Map.merge params, all_params
    end
  end

  # `URI.encode_query/1` explicitly does not percent-encode spaces, but Amazon requires `%20`
  # instead of `+` in the query, so we essentially have to rewrite `URI.encode_query/1` and
  # `URI.pair/1`.
  defp percent_encode_query(query_map) do
    Enum.map_join(query_map, "&", &pair/1)
  end

  # See comment on `percent_encode_query/1`.
  defp pair({k, v}) do
    URI.encode(Kernel.to_string(k), &URI.char_unreserved?/1) <>
    "=" <> URI.encode(Kernel.to_string(v), &URI.char_unreserved?/1)
  end

  def build_url(url, secret) do
    url |> URI.parse |> timestamp_url |> sign_url(secret) |> String.Chars.to_string
  end

  defp timestamp_url(url_parts) do
    update_url url_parts, "Timestamp", Timex.format!(Timex.local, "{ISO:Extended:Z}")
  end

  defp sign_url(url_parts, secret) do
    hmac = :crypto.hmac(
        :sha256,
        secret,
        Enum.join(["GET", url_parts.host, url_parts.path, url_parts.query], "\n")
      )
    signature = Base.encode64(hmac)
    update_url url_parts, "Signature", signature
  end

  defp update_url(url_parts, key, value) do
    updated_query = url_parts.query
                        |> URI.decode_query
                        |> Map.put_new(key, value)
                        |> percent_encode_query
    Map.put url_parts, :query, updated_query
  end
end
