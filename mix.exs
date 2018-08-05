defmodule Osabie.MixProject do
  use Mix.Project

  def project do
    [
      app: :osabie,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript(),
      preferred_cli_env: [
        "coveralls": :test,
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
      {:memoize, "~> 1.2"},
      {:excoveralls, "~> 0.9.1", only: :test}
    ]
  end

  defp escript do
    [
      main_module: Osabie.CLI
    ]
  end
end
