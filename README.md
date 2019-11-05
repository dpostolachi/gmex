# Gmex

[![Build Status](https://travis-ci.org/dpostolachi/gmex.png?branch=master)](https://travis-ci.org/dpostolachi/gmex)

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
    {:gmex, "~> 0.1.7"}
  ]
end
```

## Usage example

```elixir
import Gmex
Gmex.open( "someimage.png" )
    |> options( negate: true, resize: { 50, 50 }, strip: true, format: "jpg" )
    |> save( "newimage.jpg" )
```

## Resizing

```elixir
import Gmex
Gmex.open( "someimage.png" )
    |> resize( width: 300, height: 200, type: :fit )
    |> save( "resized.jpg" )
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/gmex](https://hexdocs.pm/gmex).
