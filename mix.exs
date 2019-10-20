defmodule Gmex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :gmex,
      version: "0.1.5",
      elixir: "~> 1.2",
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
        {:earmark, "~> 1.4", only: :dev},
        {:ex_doc, "~> 0.19", only: :dev},
        {:dialyxir, "~> 0.5", only: [:dev], runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end

  defp package do
      [
          name: "gmex",
          files: [ "lib", "mix.exs", "README.md" ],
          licenses: [ "MIT" ],
          links: %{
              "GitHub" => "https://github.com/dpostolachi/gmex"
          },
          maintainers: [ "dpostolachi" ]
      ]
  end

  defp description do
      "A simple GraphicsMagick wrapper for Elixir."
  end

end
