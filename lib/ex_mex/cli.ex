defmodule ExMex.CLI do

  @command_line_flags [side: :string, amount: :integer, price: :float, stop: :float, testnet: :boolean]
  @command_line_aliases [s: :side, a: :amount, p: :price, s: :stop]

  def main(argv) do
    {parsed, rest} = OptionParser.parse!(argv, strict: @command_line_flags, aliases: @command_line_aliases)

    unless Enum.all?(parsed, &valid_option/1) do
      usage()
    end

    options = Enum.into(parsed, %{})

  rescue
    e in OptionParser.ParseError -> usage()
  end

  defp usage do
    IO.puts "Usage:\n"
    IO.puts "./ex_mex -s <long|short> -a <amount> -p <price> [-s <stop_percentage>] [--testnet]"
    IO.puts "\nRequired Values:\n"
    IO.puts "side -s must be either 'long' or 'short'"
    IO.puts "amount -a must be a positive integer"
    IO.puts "price -p must be a positive value, either an integer or a decimal with $0.5 increments"
    IO.puts "\nOptional Values:\n"
    IO.puts "stop_percentage -s must be a positive value greater than 0 and smaller than 100. e.g. 2 which translates to 2%"
    IO.puts "--testnet uses BitMEX's testnet, test things here first"

    exit(:normal)
  end

  defp valid_option?({option, value}) when option == :side, do: Enum.member?(["long", "short", value])
  defp valid_option?({option, value}) when option == :amount, do: value > 0
  defp valid_option?({option, value}) when option == :price, do: value > 0.0 and [1, 2].member?((Float.ratio(value) |> elem(1)))
  defp valid_option?({option, value}) when option == :stop, do: value > 0 and stop < 100
  defp valid_option?({option, value}) when option == :testnet, do: is_boolean(value)
end
