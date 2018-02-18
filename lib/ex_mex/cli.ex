defmodule ExMex.CLI do


  def main([command | rest] = argv) when is_list(argv) and length(argv) >= 1 do
    config = load_api_keys()

    case command do
      "trade" -> ExMex.CLI.Trade.process_args(config, rest)
      "help" -> ExMex.CLI.Help.print_usage()
    end
  end

  def main([]) do
    ExMex.CLI.Help.print_usage()
  end

  defp load_api_keys do
    config_filename_path()
    |> YamlElixir.read_all_from_file()
    |> hd()
    |> atomize_keys()
  end

  defp config_filename_path do
    File.cwd!() |> Path.join("config.yaml")
  end

  defp atomize_keys(map) do
    map |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end) |> Enum.into(%{})
  end


end
