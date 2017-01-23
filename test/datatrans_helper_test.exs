defmodule DatatransHelperTest do
  use ExUnit.Case
  use Quixir

  import DatatransHelper

  doctest DatatransHelper

  @property_merchant_id pick_one(from: [string(min: 1), int(min: 1)])
  @property_amount float(min: 0.1)
  @property_currency string(min: 3, max: 3)
  @property_reference string()
  @property_hmac_key string(chars: ?A..?Z)

  test "map has same output as config" do
    ptest [
      merchant_id: @property_merchant_id,
      amount: @property_amount,
      currency: @property_currency,
      reference: @property_reference,
      hmac_key: @property_hmac_key
    ] do
      Application.put_env(:datatrans_helper, :merchant_id, merchant_id)
      Application.put_env(:datatrans_helper, :hmac_key, hmac_key)

      payment_info = generate_payment_info(amount, currency, reference)

      assert payment_info[:merchant_id] == if is_integer(merchant_id), do: Integer.to_string(merchant_id), else: merchant_id
      assert payment_info[:amount] == amount
      assert payment_info[:currency] == currency
      assert payment_info[:refno] == reference
      assert payment_info[:sign] == :crypto.hmac(:sha256, hmac_key,
        (if is_integer(merchant_id), do: Integer.to_string(merchant_id), else: merchant_id) <>
        Float.to_string(amount) <>
        currency <>
        reference
      ) |> Base.encode16
    end
  end
end
