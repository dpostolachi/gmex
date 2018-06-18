# Gmex

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `gmex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:gmex, "~> 0.1.0"}
  ]
end
```

## Usage example

```elixir
import Gmex
open( "someimage.png" )
    |> option( :negate )
    |> option( { :resize, 50, 50 } )
    |> option( :strip )
    |> option( { :format, "jpg" } )
    |> save( "newimage.jpg" )
```


Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/gmex](https://hexdocs.pm/gmex).
