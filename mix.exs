defmodule Osabie.MixProject do
  use Mix.Project

  def project do
    [
      app: :osabie,
      version: "1.0.1",
      elixir: ">= 1.6.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.html": :test,
        "coveralls.json": :test,
      ],
      test_coverage: [tool: ExCoveralls]
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
      {:memoize, "~> 1.4"},
      {:httpoison, "~> 1.8"},
      {:excoveralls, "~> 0.14.4", only: :test},
      {:mock, "~> 0.3.7"}
    ]
  end

  defp escript do
    [
      main_module: Osabie.CLI
    ]
  end
end
