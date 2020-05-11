defmodule DatatransHelper do
  @moduledoc """
  Small Helper Function to sign Datatrans Request Parameters
  """

  @type signature :: String.t()
  @type amount :: non_neg_integer
  @type merchant_id :: String.t()
  @type currency :: String.t()
  @type reference_number :: String.t()
  @type upp_transaction_id :: non_neg_integer
  @type datatrans_payment_request :: %{
          merchant_id: merchant_id,
          amount: amount,
          currency: currency,
          refno: reference_number,
          sign: signature
        }

  @doc """
  Generate signature of a Datatrans Request Parameters

  ### Examples

      iex> Application.put_env(:datatrans_helper, :merchant_id, "73452")
      iex> Application.put_env(:datatrans_helper, :sign1_hmac_key, "16ee1f9c0204842aed558fd57fd38503421dd6876269ad82d490ae5a7d5454d2dd936102190e86d06412ce94631fc96b6215da5fe0a5d1687dba5c5fa351e0fb")
      iex> DatatransHelper.generate_sign1(7_20, "CHF", "a5e511e9-7334-44c2-be21-cef964091739")
      "1dbf3321ef16b02a638762bc30aa9811ce696656ea49e362a452166020c976c5"

  """
  @spec generate_sign1(amount, currency, reference_number) :: signature
  def generate_sign1(amount, currency, reference) when amount > 0 do
    :sha256
    |> :crypto.hmac(
      get_sign1_hmac_key(),
      get_merchant_id() <>
        Integer.to_string(amount) <>
        currency <>
        reference
    )
    |> Base.encode16()
    |> String.downcase()
  end

  if Code.ensure_compiled?(Money) do
    @doc """
    Generate signature of a Datatrans Request Parameters

    This function is only present, if the optional `money` package is installed.

    ### Examples

        iex> Application.put_env(:datatrans_helper, :merchant_id, "73452")
        iex> Application.put_env(:datatrans_helper, :sign1_hmac_key, "16ee1f9c0204842aed558fd57fd38503421dd6876269ad82d490ae5a7d5454d2dd936102190e86d06412ce94631fc96b6215da5fe0a5d1687dba5c5fa351e0fb")
        iex> DatatransHelper.generate_sign1(Money.new(7_20, :CHF), "a5e511e9-7334-44c2-be21-cef964091739")
        "1dbf3321ef16b02a638762bc30aa9811ce696656ea49e362a452166020c976c5"

    """
    @spec generate_sign1(Money.t(), reference_number) :: signature
    def generate_sign1(%Money{amount: amount, currency: currency}, reference) when amount > 0 do
      generate_sign1(amount, Atom.to_string(currency), reference)
    end
  end

  @doc """
  Check if sign1 signature is correct

  ### Examples

      iex> Application.put_env(:datatrans_helper, :merchant_id, "73452")
      iex> Application.put_env(:datatrans_helper, :sign1_hmac_key, "16ee1f9c0204842aed558fd57fd38503421dd6876269ad82d490ae5a7d5454d2dd936102190e86d06412ce94631fc96b6215da5fe0a5d1687dba5c5fa351e0fb")
      iex> DatatransHelper.valid_sign1?("1dbf3321ef16b02a638762bc30aa9811ce696656ea49e362a452166020c976c5", 7_20, "CHF", "a5e511e9-7334-44c2-be21-cef964091739")
      true

      iex> Application.put_env(:datatrans_helper, :merchant_id, "73452")
      iex> Application.put_env(:datatrans_helper, :sign1_hmac_key, "16ee1f9c0204842aed558fd57fd38503421dd6876269ad82d490ae5a7d5454d2dd936102190e86d06412ce94631fc96b6215da5fe0a5d1687dba5c5fa351e0fb")
      iex> DatatransHelper.valid_sign1?("invalid signature", 7_20, "CHF", "a5e511e9-7334-44c2-be21-cef964091739")
      false

  """
  @spec valid_sign1?(signature, amount, currency, reference_number) :: boolean
  def valid_sign1?(sign1, amount, currency, reference) do
    sign1 == generate_sign1(amount, currency, reference)
  end

  if Code.ensure_compiled?(Money) do
    @doc """
    Check if sign1 signature is correct

    This function is only present, if the optional `money` package is installed.

    ### Examples

        iex> Application.put_env(:datatrans_helper, :merchant_id, "73452")
        iex> Application.put_env(:datatrans_helper, :sign1_hmac_key, "16ee1f9c0204842aed558fd57fd38503421dd6876269ad82d490ae5a7d5454d2dd936102190e86d06412ce94631fc96b6215da5fe0a5d1687dba5c5fa351e0fb")
        iex> DatatransHelper.valid_sign1?("1dbf3321ef16b02a638762bc30aa9811ce696656ea49e362a452166020c976c5", Money.new(7_20, "CHF"), "a5e511e9-7334-44c2-be21-cef964091739")
        true

        iex> Application.put_env(:datatrans_helper, :merchant_id, "73452")
        iex> Application.put_env(:datatrans_helper, :sign1_hmac_key, "16ee1f9c0204842aed558fd57fd38503421dd6876269ad82d490ae5a7d5454d2dd936102190e86d06412ce94631fc96b6215da5fe0a5d1687dba5c5fa351e0fb")
        iex> DatatransHelper.valid_sign1?("invalid signature", Money.new(7_20, "CHF"), "a5e511e9-7334-44c2-be21-cef964091739")
        false

    """
    @spec valid_sign1?(signature, Money.t(), reference_number) :: boolean
    def valid_sign1?(sign1, %Money{amount: amount, currency: currency}, reference) do
      valid_sign1?(sign1, amount, Atom.to_string(currency), reference)
    end
  end

  @doc """
  Generate signature of a Datatrans Post Response

  ### Examples

      iex> Application.put_env(:datatrans_helper, :merchant_id, "73452")
      iex> Application.put_env(:datatrans_helper, :sign2_hmac_key, "16ee1f9c0204842aed558fd57fd38503421dd6876269ad82d490ae5a7d5454d2dd936102190e86d06412ce94631fc96b6215da5fe0a5d1687dba5c5fa351e0fb")
      iex> DatatransHelper.generate_sign2(7_20, "CHF", 43575623879)
      "8037d669282680ed81f510b41b0622b7ce17e644fef620baf6494146313e2269"
  """
  @spec generate_sign2(amount, currency, upp_transaction_id) :: signature
  def generate_sign2(amount, currency, upp_transaction_id) when amount > 0 do
    :sha256
    |> :crypto.hmac(
      get_sign2_hmac_key(),
      get_merchant_id() <>
        Integer.to_string(amount) <>
        currency <>
        Integer.to_string(upp_transaction_id)
    )
    |> Base.encode16()
    |> String.downcase()
  end

  if Code.ensure_compiled?(Money) do
    @doc """
    Generate signature of a Datatrans Post Response

    This function is only present, if the optional `money` package is installed.

    ### Examples

        iex> Application.put_env(:datatrans_helper, :merchant_id, "73452")
        iex> Application.put_env(:datatrans_helper, :sign2_hmac_key, "16ee1f9c0204842aed558fd57fd38503421dd6876269ad82d490ae5a7d5454d2dd936102190e86d06412ce94631fc96b6215da5fe0a5d1687dba5c5fa351e0fb")
        iex> DatatransHelper.generate_sign2(Money.new(7_20, :CHF), 43575623879)
        "8037d669282680ed81f510b41b0622b7ce17e644fef620baf6494146313e2269"

    """
    @spec generate_sign2(Money.t(), upp_transaction_id) :: signature
    def generate_sign2(%Money{amount: amount, currency: currency}, upp_transaction_id)
        when amount > 0 do
      generate_sign2(amount, Atom.to_string(currency), upp_transaction_id)
    end
  end

  @doc """
  Check if sign2 signature is correct

  ### Examples

      iex> Application.put_env(:datatrans_helper, :merchant_id, "73452")
      iex> Application.put_env(:datatrans_helper, :sign2_hmac_key, "16ee1f9c0204842aed558fd57fd38503421dd6876269ad82d490ae5a7d5454d2dd936102190e86d06412ce94631fc96b6215da5fe0a5d1687dba5c5fa351e0fb")
      iex> DatatransHelper.valid_sign2?("8037d669282680ed81f510b41b0622b7ce17e644fef620baf6494146313e2269", 7_20, "CHF", 43575623879)
      true

      iex> Application.put_env(:datatrans_helper, :merchant_id, "73452")
      iex> Application.put_env(:datatrans_helper, :sign2_hmac_key, "16ee1f9c0204842aed558fd57fd38503421dd6876269ad82d490ae5a7d5454d2dd936102190e86d06412ce94631fc96b6215da5fe0a5d1687dba5c5fa351e0fb")
      iex> DatatransHelper.valid_sign2?("invalid signature", 7_20, "CHF", 43575623879)
      false

  """
  @spec valid_sign2?(signature, amount, currency, upp_transaction_id) :: boolean
  def valid_sign2?(sign2, amount, currency, upp_transaction_id) do
    sign2 == generate_sign2(amount, currency, upp_transaction_id)
  end

  if Code.ensure_compiled?(Money) do
    @doc """
    Check if sign2 signature is correct

    This function is only present, if the optional `money` package is installed.

    ### Examples

        iex> Application.put_env(:datatrans_helper, :merchant_id, "73452")
        iex> Application.put_env(:datatrans_helper, :sign2_hmac_key, "16ee1f9c0204842aed558fd57fd38503421dd6876269ad82d490ae5a7d5454d2dd936102190e86d06412ce94631fc96b6215da5fe0a5d1687dba5c5fa351e0fb")
        iex> DatatransHelper.valid_sign2?("8037d669282680ed81f510b41b0622b7ce17e644fef620baf6494146313e2269", Money.new(7_20, "CHF"), 43575623879)
        true

        iex> Application.put_env(:datatrans_helper, :merchant_id, "73452")
        iex> Application.put_env(:datatrans_helper, :sign2_hmac_key, "16ee1f9c0204842aed558fd57fd38503421dd6876269ad82d490ae5a7d5454d2dd936102190e86d06412ce94631fc96b6215da5fe0a5d1687dba5c5fa351e0fb")
        iex> DatatransHelper.valid_sign2?("invalid signature", Money.new(7_20, "CHF"), 43575623879)
        false

    """
    @spec valid_sign2?(signature, Money.t(), upp_transaction_id) :: boolean
    def valid_sign2?(sign2, %Money{amount: amount, currency: currency}, upp_transaction_id) do
      valid_sign2?(sign2, amount, Atom.to_string(currency), upp_transaction_id)
    end
  end

  @doc """
  Generate Map of payment parameters.

  ### Examples

      iex> Application.put_env(:datatrans_helper, :merchant_id, "73452")
      iex> Application.put_env(:datatrans_helper, :sign1_hmac_key, "16ee1f9c0204842aed558fd57fd38503421dd6876269ad82d490ae5a7d5454d2dd936102190e86d06412ce94631fc96b6215da5fe0a5d1687dba5c5fa351e0fb")
      iex> DatatransHelper.generate_payment_info(7_20, "CHF", "a5e511e9-7334-44c2-be21-cef964091739")
      %{amount: 7_20, currency: "CHF", merchant_id: "73452",
       refno: "a5e511e9-7334-44c2-be21-cef964091739",
       sign: "1dbf3321ef16b02a638762bc30aa9811ce696656ea49e362a452166020c976c5"}

  """
  @spec generate_payment_info(amount, currency, reference_number) :: datatrans_payment_request
  def generate_payment_info(amount, currency, reference) when amount > 0 do
    %{
      merchant_id: get_merchant_id(),
      amount: amount,
      currency: currency,
      refno: reference,
      sign: generate_sign1(amount, currency, reference)
    }
  end

  if Code.ensure_compiled?(Money) do
    @doc """
    Generate Map of payment parameters.

    This function is only present, if the optional `money` package is installed.

    ### Examples

        iex> Application.put_env(:datatrans_helper, :merchant_id, "73452")
        iex> Application.put_env(:datatrans_helper, :sign1_hmac_key, "16ee1f9c0204842aed558fd57fd38503421dd6876269ad82d490ae5a7d5454d2dd936102190e86d06412ce94631fc96b6215da5fe0a5d1687dba5c5fa351e0fb")
        iex> DatatransHelper.generate_payment_info(Money.new(7_20, :CHF), "a5e511e9-7334-44c2-be21-cef964091739")
        %{amount: 7_20, currency: "CHF", merchant_id: "73452",
         refno: "a5e511e9-7334-44c2-be21-cef964091739",
         sign: "1dbf3321ef16b02a638762bc30aa9811ce696656ea49e362a452166020c976c5"}

    """
    @spec generate_payment_info(Money.t(), reference_number) :: datatrans_payment_request
    def generate_payment_info(%Money{amount: amount, currency: currency}, reference) do
      generate_payment_info(amount, Atom.to_string(currency), reference)
    end
  end

  @spec get_sign1_hmac_key() :: String.t()
  defp get_sign1_hmac_key do
    :datatrans_helper
    |> ConfigExt.fetch_env!(:sign1_hmac_key)
    |> String.upcase()
    |> Base.decode16!()
  end

  @spec get_sign2_hmac_key() :: String.t()
  defp get_sign2_hmac_key do
    :datatrans_helper
    |> ConfigExt.fetch_env!(:sign2_hmac_key)
    |> String.upcase()
    |> Base.decode16!()
  end

  @spec get_merchant_id() :: String.t() | integer
  defp get_merchant_id do
    merchant_id = ConfigExt.fetch_env!(:datatrans_helper, :merchant_id)

    if is_integer(merchant_id) do
      Integer.to_string(merchant_id)
    else
      merchant_id
    end
  end
end
