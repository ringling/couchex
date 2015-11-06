defmodule Couchex.Mixfile do
  use Mix.Project

  def project do
    [app: :couchex,
     version: "0.0.5",
     elixir: "~> 1.1",
     deps: deps]
  end

  def application do
    [applications: [:logger, :couchbeam]]
  end

  defp deps do
    [
      {:couchbeam, "1.2.1"}
    ]
  end
end
