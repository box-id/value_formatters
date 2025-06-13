defmodule Formatter.MixProject do
  use Mix.Project

  def project do
    [
      app: :value_formatters,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
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
      {:ex_doc, "~> 0.38.2", only: :dev},
      {:ex_cldr_dates_times, "~> 2.22", only: [:dev, :test]},
      {:ex_cldr_lists, "~> 2.10", only: [:dev, :test]},
      {:ex_cldr_calendars, "~> 2.1", only: [:dev, :test]},
      {:mox, "~> 1.0", only: [:dev, :test]},
      {:timex, "~> 3.7", only: :test},
      {:ok, "~> 2.3.0"}
    ]
  end
end
