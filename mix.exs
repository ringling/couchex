defmodule Couchex.Mixfile do
  use Mix.Project

  def project do
    [app: :couchex,
     version: "0.6.0",
     elixir: "~> 1.1",
     deps: deps]
  end

  def application do
    [applications: [:logger, :couchbeam]]
  end

  defp deps do
    [
      {:couchbeam, github: "benoitc/couchbeam", tag: "1.1.7"}
    ]
  end
end
