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

  def long(pid, price, amount, symbol \\ "XBTUSD") do
    order = Order.build(:buy, price, amount, :limit, symbol)
    ExMex.post_order(pid, order)
  end

  def short(pid, price, amount, symbol \\ "XBTUSD") do
    order = Order.build(:sell, price, amount, :limit, symbol)
    ExMex.post_order(pid, order)
  end

  def long_with_stop(pid, price, amount, percentage, symbol \\ "XBTUSD") do
    long = Order.build(:buy, price, amount, :limit, symbol)
    stop = Order.stop_for(long, percentage)

    ExMex.post_orders(pid, [long, stop])
  end

  def short_with_stop(pid, price, amount, percentage, symbol \\ "XBTUSD") do
    short = Order.build(:sell, price, amount, :limit, symbol)
    stop = Order.stop_for(short, percentage)

    ExMex.post_orders(pid, [short, stop])
  end

  def post_order(pid, order) do
    GenServer.call(pid, {:post_order, order})
  end

  def post_orders(pid, orders) do
    GenServer.call(pid, {:post_orders, orders})
  end

  def cancel_order(pid, order_id) do
    GenServer.call(pid, {:cancel_order, order_id})
  end

  def cancel_all_orders(pid) do
    GenServer.call(pid, :cancel_all_orders)
  end

  # Callbacks

  def init(opts) do
    api_url = case opts[:testnet] do
                true -> "https://testnet.bitmex.com"
                false -> "https://www.bitmex.com"
              end

    state = %ExMex{api_key: opts[:api_key], api_secret: opts[:api_secret], api_url: api_url, testnet: opts[:testnet]}

    {:ok, state}
  end

  def handle_call({:get_orders, only_open}, _, state) do
    orders = ExMex.OrdersAPI.get_orders(only_open, state)
    {:reply, orders, state}
  end

  def handle_call({:post_order, order}, _, state) do
    order = ExMex.OrdersAPI.post_order(order, state)
    {:reply, order, state}
  end

  def handle_call({:post_orders, orders}, _, state) do
    orders = ExMex.OrdersAPI.post_orders(orders, state)
    {:reply, orders, state}
  end

  def handle_call({:cancel_order, order_id}, _, state) do
    order = ExMex.OrdersAPI.cancel_order(order_id, state)
    {:reply, order, state}
  end

  def handle_call(:cancel_all_orders, _, state) do
    order = ExMex.OrdersAPI.cancel_all_orders(state)
    {:reply, order, state}
  end
end
