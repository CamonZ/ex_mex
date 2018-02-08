defmodule ExMex.CLI do

  @command_line_flags [side: :string, amount: :integer, price: :float, stop: :float, testnet: :boolean]
  @command_line_aliases [s: :side, a: :amount, p: :price, sp: :stop]

  def main(argv) do
    commands = parse_args(argv)
    config = Map.put(load_api_keys(), :testnet, commands[:testnet])

    {:ok, client} = ExMex.start_link(config)

    orders = ExMex.process_from_cli(client, commands)

  rescue
    _ in OptionParser.ParseError -> usage()
  end

  defp parse_args(argv) do
    {parsed, _} = OptionParser.parse!(argv, strict: @command_line_flags, aliases: @command_line_aliases)

    unless Enum.all?(parsed, &valid_option?/1) do
      usage()
    end
    Enum.into(parsed,%{})
  end

  defp load_api_keys do
    YamlElixir.read_all_from_file(config_filename_path()) |> atomize_keys()
  end

  defp config_filename_path do
    File.cwd!() |> Path.join("config.yaml")
  end

  defp atomize_keys(map) do
    map |> Enum.map(fn({k, v}) -> {String.to_existing_atom(k), v} end) |> Enum.into(%{})
  end

  defp usage do
    IO.puts "Usage:\n"
    IO.puts "./ex_mex -s <long|short> -a <amount> -p <price> [-sp <stop_percentage>] [--testnet]"
    IO.puts "\nRequired Values:\n"
    IO.puts "side -s must be either 'long' or 'short'"
    IO.puts "amount -a must be a positive integer"
    IO.puts "price -p must be a positive value in $0.5 increments"
    IO.puts "\nOptional Values:\n"
    IO.puts "stop_percentage -sp must be a positive value greater than 0 and smaller than 100. e.g. 2 which translates to 2%"
    IO.puts "--testnet uses BitMEX's testnet, test things here first"

    exit(:normal)
  end

  defp valid_option?({option, value}) when option == :side, do: Enum.member?(["long", "short"], value)
  defp valid_option?({option, value}) when option == :amount, do: value > 0
  defp valid_option?({option, value}) when option == :price, do: value > 0.0 and Enum.member?([1, 2], Float.ratio(value) |> elem(1))
  defp valid_option?({option, value}) when option == :stop, do: value > 0 and value < 100
  defp valid_option?({option, value}) when option == :testnet, do: is_boolean(value)
end
