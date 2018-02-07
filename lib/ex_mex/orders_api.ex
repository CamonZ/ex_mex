defmodule ExMex.OrdersAPI do
  alias ExMex.ApiClient

  def get_orders(false, config) do
    request = %{verb: "GET", path: "/api/v1/order"}
    ApiClient.do_request(request, config)
  end

  def get_orders(true, config) do
    filter = Poison.encode!(%{open: true})
    request = %{verb: "GET", path: "/api/v1/order", query: %{filter: filter}}

    ApiClient.do_request(request, config)
  end

  def post_order(order, config) do
    request = %{verb: "POST", path: "/api/v1/order", data: serialize(order)}
    ApiClient.do_request(request, config)
  end

  def post_orders(orders, config) do
    request = %{verb: "POST", path: "/api/v1/order/bulk", data: %{orders: Poison.encode!(Enum.map(orders, &serialize/1)) }}
    ApiClient.do_request(request, config)
  end

  def cancel_order(order_id, config) do
    request = %{verb: "DELETE", path: "/api/v1/order", data: %{orderID: order_id}}
    ApiClient.do_request(request, config)
  end

  def cancel_all_orders(config) do
    request = %{verb: "DELETE", path: "/api/v1/order/all", data: %{}}
    ApiClient.do_request(request, config)
  end

  defp serialize(order) do
    order
    |> Map.from_struct()
    |> Enum.reject(fn({_,v}) -> is_nil(v) end)
    |> Enum.into(%{})
  end
end
