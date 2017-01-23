# DatatransHelper

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/jshmrtn/datatrans-helper/master/LICENSE)
[![Build Status](https://travis-ci.org/jshmrtn/datatrans-helper.svg?branch=master)](https://travis-ci.org/jshmrtn/datatrans-helper)
[![Hex.pm Version](https://img.shields.io/hexpm/v/datatrans-helper.svg?style=flat)](https://hex.pm/packages/datatrans_helper)
[![InchCI](https://inch-ci.org/github/jshmrtn/datatrans-helper.svg?branch=master)](https://inch-ci.org/github/jshmrtn/datatrans-helper)
[![Coverage Status](https://coveralls.io/repos/github/jshmrtn/datatrans-helper/badge.svg?branch=master)](https://coveralls.io/github/jshmrtn/datatrans-helper?branch=master)

Small Helper Function to sign Datatrans Request Parameters.

## Installation

The package can be installed
by adding `datatrans_helper` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:datatrans_helper, "~> 0.1.0"}]
end
```

## Configuration
```elixir
config :datatrans_helper,
  merchant_id: "Some ID",
  hmac_key: "Some Key"
```

## Documentation

The docs can
be found at [https://hexdocs.pm/datatrans_helper](https://hexdocs.pm/datatrans_helper).

## Usage
```elixir
DatatransHelper.generate_payment_info(7.2, "CHF", "a5e511e9-7334-44c2-be21-cef964091739")
%{amount: 7.2, currency: "CHF", merchant_id: "73452",
 refno: "a5e511e9-7334-44c2-be21-cef964091739",
 sign: "1EC9627CC7BA2E58251656BD500672BB6C5509FD569BB31737EE381C56CFE785"}
```
