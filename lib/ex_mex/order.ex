defmodule ExMex.Order do

  alias __MODULE__

  defstruct side: nil, ordType: nil, orderQty: nil, symbol: nil, price: nil, stopPx: nil

  def build(side, price, quantity, type, symbol) do
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

  defp generic_order(quantity, symbol), do: %Order{symbol: symbol, orderQty: quantity}
  defp process_side(order, side), do: order |> Map.merge(%{side: camelize(side)})
  defp process_type(order, type), do: order |> Map.merge(%{ordType: camelize(type)})

  defp process_price(%{ordType: type} = order, price) when type == "StopLimit",
    do: order |>  Map.merge(%{stopPx: price, price: price})

  defp process_price(%{ordType: type} = order, price) when type == "Stop",
    do: order |> Map.merge(%{stopPx: price})

  defp process_price(%{ordType: type} = order, price) when type == "Limit",
    do: order |> Map.merge(%{price: price})

  defp process_price(order, price),
    do: order

  defp camelize(atom) when is_atom(atom),
    do: Atom.to_string(atom) |> String.split("_") |> Enum.map(&String.capitalize/1) |> Enum.join("")

  defp stop_price(side, price, percentage) when side == "Buy", do: price * ((100 - percentage) / 100)
  defp stop_price(side, price, percentage) when side == "Sell", do: price * ((100 + percentage) / 100)
end
