defmodule Couchex.Mixfile do
  use Mix.Project

  def project do
    [app: :couchex,
     version: "0.7.1",
     elixir: "~> 1.3",
     package: package(),
     description: description(),
     deps: deps()]
  end

  def application do
    [applications: [:logger, :couchbeam_amuino]]
  end

  defp deps do
    [
      #{:couchbeam, github: "ringling/couchbeam"},
      {:couchbeam_amuino, "~> 1.4.3-amuino.5"},
      {:ex_doc, "~> 0.11", only: :dev},
      {:earmark, ">= 0.0.0"},
      {:poison, "~> 3.0"}
    ]
  end

  defp description do
    """
    CouchDB client, wrapping couchbeam erlang client.
    """
  end

  defp package do
    [
      files: ~w(lib mix.exs README.md LICENSE CHANGELOG.md),
      maintainers: ["Thomas Ringling"],
      licenses: ["Unlicense"],
      links: %{"GitHub" => "https://github.com/ringling/couchex"}
   ]
  end
end
