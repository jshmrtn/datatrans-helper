defmodule DatatransHelperTest do
  @moduledoc false

  use ExUnit.Case
  use Quixir

  import DatatransHelper

  doctest DatatransHelper

  @property_merchant_id pick_one(from: [string(min: 1), int(min: 1)])
  @property_amount positive_int()
  @property_currency string(min: 3, max: 3, chars: :ascii)
  @property_reference string()
  @property_sign1_hmac_key string(chars: :digits, min: 128, max: 128)
  @property_sign2_hmac_key string(chars: :digits, min: 128, max: 128)
  @property_upp_transaction_id positive_int()

  describe "generate_sign1/3" do
    test "map has same output as config" do
      ptest merchant_id: @property_merchant_id,
            amount: @property_amount,
            currency: @property_currency,
            reference: @property_reference,
            sign1_hmac_key: @property_sign1_hmac_key do
        Application.put_env(:datatrans_helper, :merchant_id, merchant_id)
        Application.put_env(:datatrans_helper, :sign1_hmac_key, sign1_hmac_key)

        signature = generate_sign1(amount, currency, reference)

        expected =
          :sha256
          |> :crypto.hmac(
            Base.decode16!(sign1_hmac_key),
            if(is_integer(merchant_id), do: Integer.to_string(merchant_id), else: merchant_id) <>
              Integer.to_string(amount) <>
              currency <>
              reference
          )
          |> Base.encode16()
          |> String.downcase()

        assert signature == expected
      end
    end
  end

  describe "generate_sign1/2" do
    test "map has same output as config" do
      ptest merchant_id: @property_merchant_id,
            amount: @property_amount,
            currency: @property_currency,
            reference: @property_reference,
            sign1_hmac_key: @property_sign1_hmac_key do
        Application.put_env(:datatrans_helper, :merchant_id, merchant_id)
        Application.put_env(:datatrans_helper, :sign1_hmac_key, sign1_hmac_key)

        signature =
          generate_sign1(%Money{amount: amount, currency: String.to_atom(currency)}, reference)

        expected =
          :sha256
          |> :crypto.hmac(
            Base.decode16!(sign1_hmac_key),
            if(is_integer(merchant_id), do: Integer.to_string(merchant_id), else: merchant_id) <>
              Integer.to_string(amount) <>
              currency <>
              reference
          )
          |> Base.encode16()
          |> String.downcase()

        assert signature == expected
      end
    end
  end

  describe "valid_sign1?/3" do
    test "verifies correctly" do
      ptest merchant_id: @property_merchant_id,
            amount: @property_amount,
            currency: @property_currency,
            reference: @property_reference,
            sign1_hmac_key: @property_sign1_hmac_key do
        Application.put_env(:datatrans_helper, :merchant_id, merchant_id)
        Application.put_env(:datatrans_helper, :sign1_hmac_key, sign1_hmac_key)

        signature =
          :sha256
          |> :crypto.hmac(
            Base.decode16!(sign1_hmac_key),
            if(is_integer(merchant_id), do: Integer.to_string(merchant_id), else: merchant_id) <>
              Integer.to_string(amount) <>
              currency <>
              reference
          )
          |> Base.encode16()
          |> String.downcase()

        assert valid_sign1?(signature, amount, currency, reference)
        refute valid_sign1?("something", amount, currency, reference)
      end
    end
  end

  describe "valid_sign1?/2" do
    test "verifies correctly" do
      ptest merchant_id: @property_merchant_id,
            amount: @property_amount,
            currency: @property_currency,
            reference: @property_reference,
            sign1_hmac_key: @property_sign1_hmac_key do
        Application.put_env(:datatrans_helper, :merchant_id, merchant_id)
        Application.put_env(:datatrans_helper, :sign1_hmac_key, sign1_hmac_key)

        signature =
          :sha256
          |> :crypto.hmac(
            Base.decode16!(sign1_hmac_key),
            if(is_integer(merchant_id), do: Integer.to_string(merchant_id), else: merchant_id) <>
              Integer.to_string(amount) <>
              currency <>
              reference
          )
          |> Base.encode16()
          |> String.downcase()

        assert valid_sign1?(
                 signature,
                 %Money{amount: amount, currency: String.to_atom(currency)},
                 reference
               )

        refute valid_sign1?(
                 "something",
                 %Money{amount: amount, currency: String.to_atom(currency)},
                 reference
               )
      end
    end
  end

  describe "generate_payment_info/3" do
    test "map has same output as config" do
      ptest merchant_id: @property_merchant_id,
            amount: @property_amount,
            currency: @property_currency,
            reference: @property_reference,
            sign1_hmac_key: @property_sign1_hmac_key do
        Application.put_env(:datatrans_helper, :merchant_id, merchant_id)
        Application.put_env(:datatrans_helper, :sign1_hmac_key, sign1_hmac_key)

        payment_info = generate_payment_info(amount, currency, reference)

        signature =
          :sha256
          |> :crypto.hmac(
            Base.decode16!(sign1_hmac_key),
            if(is_integer(merchant_id), do: Integer.to_string(merchant_id), else: merchant_id) <>
              Integer.to_string(amount) <>
              currency <>
              reference
          )
          |> Base.encode16()
          |> String.downcase()

        assert payment_info[:merchant_id] ==
                 if(is_integer(merchant_id), do: Integer.to_string(merchant_id), else: merchant_id)

        assert payment_info[:amount] == amount
        assert payment_info[:currency] == currency
        assert payment_info[:refno] == reference
        assert payment_info[:sign] == signature
      end
    end
  end

  describe "generate_payment_info/2" do
    test "map has same output as config" do
      ptest merchant_id: @property_merchant_id,
            amount: @property_amount,
            currency: @property_currency,
            reference: @property_reference,
            sign1_hmac_key: @property_sign1_hmac_key do
        Application.put_env(:datatrans_helper, :merchant_id, merchant_id)
        Application.put_env(:datatrans_helper, :sign1_hmac_key, sign1_hmac_key)

        payment_info =
          generate_payment_info(
            %Money{amount: amount, currency: String.to_atom(currency)},
            reference
          )

        signature =
          :sha256
          |> :crypto.hmac(
            Base.decode16!(sign1_hmac_key),
            if(is_integer(merchant_id), do: Integer.to_string(merchant_id), else: merchant_id) <>
              Integer.to_string(amount) <>
              currency <>
              reference
          )
          |> Base.encode16()
          |> String.downcase()

        assert payment_info[:merchant_id] ==
                 if(is_integer(merchant_id), do: Integer.to_string(merchant_id), else: merchant_id)

        assert payment_info[:amount] == amount
        assert payment_info[:currency] == currency
        assert payment_info[:refno] == reference
        assert payment_info[:sign] == signature
      end
    end
  end

  describe "generate_sign2/3" do
    ptest merchant_id: @property_merchant_id,
          amount: @property_amount,
          currency: @property_currency,
          upp_transaction_id: @property_upp_transaction_id,
          sign2_hmac_key: @property_sign2_hmac_key do
      Application.put_env(:datatrans_helper, :merchant_id, merchant_id)
      Application.put_env(:datatrans_helper, :sign2_hmac_key, sign2_hmac_key)

      signature = generate_sign2(amount, currency, upp_transaction_id)

      expected =
        :sha256
        |> :crypto.hmac(
          Base.decode16!(sign2_hmac_key),
          if(is_integer(merchant_id), do: Integer.to_string(merchant_id), else: merchant_id) <>
            Integer.to_string(amount) <>
            currency <>
            Integer.to_string(upp_transaction_id)
        )
        |> Base.encode16()
        |> String.downcase()

      assert signature == expected
    end
  end

  describe "generate_sign2/2" do
    ptest merchant_id: @property_merchant_id,
          amount: @property_amount,
          currency: @property_currency,
          upp_transaction_id: @property_upp_transaction_id,
          sign2_hmac_key: @property_sign2_hmac_key do
      Application.put_env(:datatrans_helper, :merchant_id, merchant_id)
      Application.put_env(:datatrans_helper, :sign2_hmac_key, sign2_hmac_key)

      signature =
        generate_sign2(
          %Money{amount: amount, currency: String.to_atom(currency)},
          upp_transaction_id
        )

      expected =
        :sha256
        |> :crypto.hmac(
          Base.decode16!(sign2_hmac_key),
          if(is_integer(merchant_id), do: Integer.to_string(merchant_id), else: merchant_id) <>
            Integer.to_string(amount) <>
            currency <>
            Integer.to_string(upp_transaction_id)
        )
        |> Base.encode16()
        |> String.downcase()

      assert signature == expected
    end
  end

  describe "valid_sign2?/3" do
    test "verifies correctly" do
      ptest merchant_id: @property_merchant_id,
            amount: @property_amount,
            currency: @property_currency,
            upp_transaction_id: @property_upp_transaction_id,
            sign2_hmac_key: @property_sign2_hmac_key do
        Application.put_env(:datatrans_helper, :merchant_id, merchant_id)
        Application.put_env(:datatrans_helper, :sign2_hmac_key, sign2_hmac_key)

        signature =
          :sha256
          |> :crypto.hmac(
            Base.decode16!(sign2_hmac_key),
            if(is_integer(merchant_id), do: Integer.to_string(merchant_id), else: merchant_id) <>
              Integer.to_string(amount) <>
              currency <>
              Integer.to_string(upp_transaction_id)
          )
          |> Base.encode16()
          |> String.downcase()

        assert valid_sign2?(signature, amount, currency, upp_transaction_id)
        refute valid_sign2?("something", amount, currency, upp_transaction_id)
      end
    end
  end

  describe "valid_sign2?/2" do
    test "verifies correctly" do
      ptest merchant_id: @property_merchant_id,
            amount: @property_amount,
            currency: @property_currency,
            upp_transaction_id: @property_upp_transaction_id,
            sign2_hmac_key: @property_sign2_hmac_key do
        Application.put_env(:datatrans_helper, :merchant_id, merchant_id)
        Application.put_env(:datatrans_helper, :sign2_hmac_key, sign2_hmac_key)

        signature =
          :sha256
          |> :crypto.hmac(
            Base.decode16!(sign2_hmac_key),
            if(is_integer(merchant_id), do: Integer.to_string(merchant_id), else: merchant_id) <>
              Integer.to_string(amount) <>
              currency <>
              Integer.to_string(upp_transaction_id)
          )
          |> Base.encode16()
          |> String.downcase()

        assert valid_sign2?(
                 signature,
                 %Money{amount: amount, currency: String.to_atom(currency)},
                 upp_transaction_id
               )

        refute valid_sign2?(
                 "something",
                 %Money{amount: amount, currency: String.to_atom(currency)},
                 upp_transaction_id
               )
      end
    end
  end
end
