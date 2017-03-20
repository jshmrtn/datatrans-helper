# DatatransHelper

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/jshmrtn/datatrans-helper/master/LICENSE)
[![Build Status](https://travis-ci.org/jshmrtn/datatrans-helper.svg?branch=master)](https://travis-ci.org/jshmrtn/datatrans-helper)
[![Hex.pm Version](https://img.shields.io/hexpm/v/datatrans_helper.svg?style=flat)](https://hex.pm/packages/datatrans_helper)
[![InchCI](https://inch-ci.org/github/jshmrtn/datatrans-helper.svg?branch=master)](https://inch-ci.org/github/jshmrtn/datatrans-helper)
[![Coverage Status](https://coveralls.io/repos/github/jshmrtn/datatrans-helper/badge.svg?branch=master)](https://coveralls.io/github/jshmrtn/datatrans-helper?branch=master)

Small Helper Library to sign / validate Datatrans requests.

## Installation

The package can be installed
by adding `datatrans_helper` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:datatrans_helper, "~> 0.2.0"}]
end
```

## Configuration

```elixir
config :datatrans_helper,
  merchant_id: "Some ID",
  sign1_hmac_key: "Some Key",
  sign2_hmac_key: "Some Key"
```

![Datatrans Configuration](datatrans_configuration.png "Datatrans Configuration")

## Documentation

The docs can be found at [https://hexdocs.pm/datatrans_helper](https://hexdocs.pm/datatrans_helper).
