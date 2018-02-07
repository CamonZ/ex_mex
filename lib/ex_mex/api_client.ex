defmodule ExMex.ApiClient do
  use Tesla

  plug Tesla.Middleware.JSON


  def do_request(%{verb: verb, query: query}= request, config) when verb == "GET"  do
    get(client(request, config), request[:path], query: query).body
  end

  def do_request(%{verb: verb}= request, config) when verb == "GET" do
    get(client(request, config), request[:path]).body
  end

  def do_request(%{verb: verb, data: data}= request, config) when verb == "POST" do
    post(client(request, config), request[:path], data).body
  end

  def do_request(%{verb: verb, data: data}= request, config) when verb == "PUT" do
    put(client(request, config), request[:path], data).body
  end

  def do_request(%{verb: verb, data: data}= request, config) when verb == "DELETE" do
    delete(client(request, config), request[:path], body: data).body
  end

  def client(request, config) do
    nonce = nonce_timestamp()

    Tesla.build_client [
      {
        Tesla.Middleware.Headers, %{
          "api-key" => config.api_key,
          "api-signature" => signature(request, nonce, config),
          "api-nonce" => nonce
        }
      },
      {
        Tesla.Middleware.BaseUrl, config.api_url
      }
    ]
  end

  defp nonce_timestamp do
    DateTime.utc_now
    |> Timex.shift(minutes: 1)
    |> DateTime.to_unix(:microseconds)
  end

  defp signature(%{verb: verb, path: path, query: query}, nonce, config) do
    full_path = Tesla.build_url(path, query)
    :crypto.hmac(:sha256, config.api_secret, "#{verb}#{full_path}#{nonce}")
    |> Base.encode16
  end

  defp signature(%{verb: verb, path: path, data: data}, nonce, config) do
    :crypto.hmac(:sha256, config.api_secret, "#{verb}#{path}#{nonce}#{Poison.encode!(data)}")
    |> Base.encode16
  end

  defp signature(%{verb: verb, path: path}, nonce, config) do
    :crypto.hmac(:sha256, config.api_secret, "#{verb}#{path}#{nonce}")
    |> Base.encode16
  end
end
