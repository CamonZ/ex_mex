# ExMex

Simple client for creating and deleting orders on BitMEX

## Installation
If you plan on using the library within an elixir application add it as a dependency to your `mix.exs`

```elixir
def deps do
  [
    {:ex_mex, git: "https://github.com/camonz/ex_mex.git"}
  ]
end
```
For using the application directly through the command line, you'll first need [Elixir/Erlang installed](https://elixir-lang.org/install.html),
as well as `git` to clone the repository.

To clone the repository run:

```
git clone https://github.com/camonz/ex_mex.git
```

then switch directories to the `ex_mex` dir with `cd ex_mex` and continue with the compilation instructions


## Compilation

Run `MIX_ENV=production mix escript.build`

## API keys configuration

Copy the `config.yaml.example` file into `config.yaml` and put your `API_KEY` and `API_KEY_SECRET` in it.

## Usage

After compiling and configuring your API keys, run the app with `ex_mex -s <long|short> -a 100 -p 1000 -t 2` which translates to
long 100 contracts at $1000 with a market stop of 2% below the entry price.

For stops, given we are using percentages and we might not hit the exact tick size of $0.5 increments we adjust
it given the following rules:

* On long positions, the stop will be rounded to the nearest integer down. e.g. for a stop at $8335.74,
  it will be rounded down to $8335
* On short positions, the stop will be rounded to the nearest integer up, e.g. for a stop at 8754.24,
  the stop will be rounded up to $8755


## Donations

If you find this useful and want to help continue its development, here are the donation addresses for the project:

* BTC: 164apxFnWwGNiBGYnVYHrXSqP5WFGSsEfw
* BTC (P2SH): 3CNWZckmhpjk6VRYK6KSMWU2Aam9jNi51c
* ETH: 0x28175E0fd0077B464Cc769E115EC5acaF906370a
* NEO: Ad5nni2BgDQanXY6Zwd5qZ17bSDzaCapq2
