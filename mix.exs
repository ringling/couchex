defmodule Couchex.Mixfile do
  use Mix.Project

  def project do
    [app: :couchex,
     version: "0.0.4",
     elixir: "~> 1.1",
     deps: deps]
  end

  def application do
    [applications: [:logger, :couchbeam]]
  end

  defp deps do
    [
      {:jsx, github: "talentdeficit/jsx", tag: "2.8.0", override: true},
      {:hackney, github: "benoitc/hackney", tag: "1.4.4", override: true},
      {:couchbeam, github: "benoitc/couchbeam", tag: "1.2.1"}
    ]
  end
end
