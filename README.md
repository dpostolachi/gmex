# Gmex

[![Build Status](https://travis-ci.org/voodoo-child/gmex.png?branch=master)](https://travis-ci.org/voodoo-child/gmex)

A simple GraphicsMagick wrapper for Elixir.

## Documentation

Documentation is available here: [https://hexdocs.pm/gmex/Gmex.html](https://hexdocs.pm/gmex/Gmex.html)

## Requirements

Installed `graphicsmagick`.

Elixir ~> 1.2

Erlang/OTP ~> 18.0

## Installation

The package can be installed
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
