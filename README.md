# ExMex

Simple client for creating and deleting orders on BitMEX

## Installation

```elixir
def deps do
  [
    {:ex_mex, git: "https://github.com/camonz/ex_mex.git"}
  ]
end
```

## Compilation

Run `mix escript.build`

## API keys configuration

Copy the `config.yaml.example` file into `config.yaml` and put your `API_KEY` and `API_KEY_SECRET` in it.

## Usage

After compiling and configuring your API keys, run the app with `ex_mex -s <long|short> -a 100 -p 1000 -sp 2` which translates to
long 100 contracts at $1000 with a market stop of 2% below the entry price.
