defmodule DatatransHelper.Mixfile do
  use Mix.Project

  def project do
    [
      app: :datatrans_helper,
      version: "0.2.0",
      elixir: "~> 1.3",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  defp description do
    """
    Small Helper Function to sign Datatrans Request Parameters.
    """
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:config_ext, "~> 0.3"},
      {:money, "~> 1.2", optional: true},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:inch_ex, only: :docs},
      {:excoveralls, "~> 0.4", only: [:dev, :test]},
      {:dialyxir, "~> 0.4", only: [:dev], runtime: false},
      {:credo, "~> 0.5", only: [:dev, :test]},
      {:quixir, "~> 0.9", only: [:dev, :test]}
    ]
  end

  defp package do
    # These are the default files included in the package
    [
      name: :datatrans_helper,
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Jonatan Männchen"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/jshmrtn/datatrans-helper"}
    ]
  end
end
