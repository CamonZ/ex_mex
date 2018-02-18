defmodule ExMex do

  use GenServer

  defstruct api_key: nil, api_secret: nil, testnet: false, api_url: nil

  alias __MODULE__
  alias ExMex.Order

  # Client API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def get_orders(pid, only_open \\ false) do
    GenServer.call(pid, {:get_orders, only_open})
  end

  def post_order(pid, order) do
    GenServer.call(pid, {:post_order, order})
  end

  def post_orders(pid, orders) when is_list(orders) and length(orders) >= 1 do
    GenServer.call(pid, {:post_orders, orders})
  end

  def cancel_order(pid, order_id) do
    GenServer.call(pid, {:cancel_order, order_id})
  end

  def cancel_all_orders(pid) do
    GenServer.call(pid, :cancel_all_orders)
  end

  def process_command_from_cli(pid, %{side: side, quantity: quantity, price: price} = cli_options) do
    orders = [Order.build(side_from_string(side), price, quantity, :limit, "XBTUSD")]

    case Map.has_key?(cli_options, :stop) and not is_nil(cli_options[:stop]) do
      true -> ExMex.post_orders(pid, [Order.stop_for(hd(orders), cli_options[:stop]) | orders] |> Enum.reverse())
      false -> ExMex.post_orders(pid, orders)
    end
  end

  # Callbacks

  def init(opts) do
    api_url = case opts[:testnet] do
                true -> "https://testnet.bitmex.com"
                _ -> "https://www.bitmex.com"
              end

    state = %ExMex{api_key: opts[:api_key], api_secret: opts[:api_secret], api_url: api_url, testnet: opts[:testnet]}

    {:ok, state}
  end

  def handle_call({:get_orders, only_open}, _, state) do
    result = ExMex.OrdersAPI.get_orders(only_open, state)
    {:reply, result, state}
  end

  def handle_call({:post_order, order}, _, state) do
    result = ExMex.OrdersAPI.post_order(order, state)
    {:reply, result, state}
  end

  def handle_call({:post_orders, orders}, _, state) do
    result = ExMex.OrdersAPI.post_orders(orders, state)
    {:reply, result, state}
  end

  def handle_call({:cancel_order, order_id}, _, state) do
    result = ExMex.OrdersAPI.cancel_order(order_id, state)
    {:reply, result, state}
  end

  def handle_call(:cancel_all_orders, _, state) do
    result = ExMex.OrdersAPI.cancel_all_orders(state)
    {:reply, result, state}
  end

  # Helpers

  defp side_from_string(side) do
    case side do
      "long" -> :buy
      "short" -> :sell
    end
  end
end
