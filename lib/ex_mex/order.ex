defmodule ExMex.Order do

  alias __MODULE__

  defstruct side: nil, ordType: nil, orderQty: nil, symbol: nil, price: nil, stopPx: nil

  @valid_trade_types [:limit, :stop, :stop_limit, :market]

  def build(side, price, quantity, type, symbol) do
    generic_order(quantity, symbol)
    |> process_side(side)
    |> process_type(type)
    |> process_price(price)
  end

  def build(%{side: side, quantity: quantity, type: :market, symbol: symbol}) do
    generic_order(quantity, symbol)
    |> process_side(side)
    |> process_type(:market)
  end

  def build(%{side: side, quantity: quantity, price: price, type: type, symbol: symbol}) do
    generic_order(quantity, symbol)
    |> process_side(side)
    |> process_type(type)
    |> process_price(price)
  end

  def stop_for(%Order{side: side, price: price, orderQty: quantity, symbol: symbol}, percentage) when side == "Buy" do
    build(:sell, stop_price(side, price, percentage), quantity, :stop_limit, symbol)
  end

  def stop_for(%Order{side: side, price: price, orderQty: quantity, symbol: symbol}, percentage) when side == "Sell" do
    build(:buy, stop_price(side, price, percentage), quantity, :stop_limit, symbol)
  end

  defp generic_order(value, symbol) when not is_integer(value) do
    with {integer_value, _} <- Integer.parse(value) do
      generic_order(integer_value, symbol)
    else
      :error -> raise ArgumentError, "Order amount is not a valid integer"
    end
  end

  defp generic_order(value, symbol) do
    with :ok <- validate_quantity(value) do
      %Order{symbol: symbol, orderQty: value}
    else
      _ -> raise ArgumentError, "Order amount is not a valid integer"
    end
  end

  defp process_side(order, side) when side == :long, do: process_side(order, :buy)
  defp process_side(order, side) when side == :short, do: process_side(order, :sell)
  defp process_side(order, side) when side in [:buy, :sell], do: order |> Map.merge(%{side: camelize(side)})
  defp process_side(_, _), do: raise ArgumentError, "Unrecognized trade side"

  defp process_type(order, type) when type in @valid_trade_types, do: order |> Map.merge(%{ordType: camelize(type)})
  defp process_type(_, _), do: raise ArgumentError, "Unrecognized trade type"

  defp process_price(%{ordType: type} = order, price) when type == "StopLimit",
    do: order |>  Map.merge(%{stopPx: price, price: price})

  defp process_price(%{ordType: type} = order, price) when type == "Stop",
    do: order |> Map.merge(%{stopPx: price})

  defp process_price(%{ordType: type} = order, price) when type == "Limit",
    do: order |> Map.merge(%{price: price})

  defp process_price(order, type) when type == "Market", # When not specified, it's a Market order, we only need the amount
    do: order

  defp camelize(atom) when is_atom(atom),
    do: Atom.to_string(atom) |> String.split("_") |> Enum.map(&String.capitalize/1) |> Enum.join("")

  defp stop_price(side, price, percentage) when side == "Buy", do: price * ((100 - percentage) / 100) |> Float.floor()
  defp stop_price(side, price, percentage) when side == "Sell", do: price * ((100 + percentage) / 100) |> Float.ceil()

  defp validate_quantity(value) when value > 0, do: :ok
  defp validate_quantity(value) when value <= 0, do: :error
end
