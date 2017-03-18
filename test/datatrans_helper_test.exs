defmodule DatatransHelperTest do
  use ExUnit.Case
  use Quixir

  import DatatransHelper

  doctest DatatransHelper

  @property_merchant_id pick_one(from: [string(min: 1), int(min: 1)])
  @property_amount positive_int()
  @property_currency string(min: 3, max: 3, chars: :ascii)
  @property_reference string()
  @property_sign1_hmac_key string(chars: :digits, min: 128, max: 128)

  describe "generate_payment_info/3" do
    test "map has same output as config" do
      ptest [
        merchant_id: @property_merchant_id,
        amount: @property_amount,
        currency: @property_currency,
        reference: @property_reference,
        sign1_hmac_key: @property_sign1_hmac_key
      ] do
        Application.put_env(:datatrans_helper, :merchant_id, merchant_id)
        Application.put_env(:datatrans_helper, :sign1_hmac_key, sign1_hmac_key)

        payment_info = generate_payment_info(amount, currency, reference)

        signature = :crypto.hmac(:sha256, Base.decode16!(sign1_hmac_key),
          (if is_integer(merchant_id), do: Integer.to_string(merchant_id), else: merchant_id) <>
          Integer.to_string(amount) <>
          currency <>
          reference
        )
        |> Base.encode16
        |> String.downcase

        assert payment_info[:merchant_id] == if is_integer(merchant_id), do: Integer.to_string(merchant_id), else: merchant_id
        assert payment_info[:amount] == amount
        assert payment_info[:currency] == currency
        assert payment_info[:refno] == reference
        assert payment_info[:sign] == signature
      end
    end
  end

  describe "generate_payment_info/2" do
    test "map has same output as config" do
      ptest [
        merchant_id: @property_merchant_id,
        amount: @property_amount,
        currency: @property_currency,
        reference: @property_reference,
        sign1_hmac_key: @property_sign1_hmac_key
      ] do
        Application.put_env(:datatrans_helper, :merchant_id, merchant_id)
        Application.put_env(:datatrans_helper, :sign1_hmac_key, sign1_hmac_key)

        payment_info = generate_payment_info(%Money{amount: amount, currency: String.to_atom(currency)}, reference)

        signature = :crypto.hmac(:sha256, Base.decode16!(sign1_hmac_key),
          (if is_integer(merchant_id), do: Integer.to_string(merchant_id), else: merchant_id) <>
          Integer.to_string(amount) <>
          currency <>
          reference
        )
        |> Base.encode16
        |> String.downcase

        assert payment_info[:merchant_id] == if is_integer(merchant_id), do: Integer.to_string(merchant_id), else: merchant_id
        assert payment_info[:amount] == amount
        assert payment_info[:currency] == currency
        assert payment_info[:refno] == reference
        assert payment_info[:sign] == signature
      end
    end
  end
end
