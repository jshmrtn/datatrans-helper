defmodule DatatransHelper do

  @type datatrans_payment_request :: %{merchant_id: String.t, amount: float, currency: String.t, refno: String.t, sign: String.t}

  @moduledoc """
  Small Helper Function to sign Datatrans Request Parameters
  """

  @doc """
  Generate Map of payment parameters.

  ### Examples

      iex> Application.put_env(:datatrans_helper, :merchant_id, "73452")
      iex> Application.put_env(:datatrans_helper, :sign1_hmac_key, "your_key")
      iex> DatatransHelper.generate_payment_info(7_20, "CHF", "a5e511e9-7334-44c2-be21-cef964091739")
      %{amount: 7_20, currency: "CHF", merchant_id: "73452",
       refno: "a5e511e9-7334-44c2-be21-cef964091739",
       sign: "2A28243478E60BF7CC5D418D99A00287173DA3963AA5B3459830DBDDB86EB648"}

  """
  @spec generate_payment_info(non_neg_integer, String.t, String.t) :: datatrans_payment_request
  def generate_payment_info(amount, currency, reference) when amount > 0 do
    sign %{
      merchant_id: get_merchant_id(),
      amount: amount,
      currency: currency,
      refno: reference
    }
  end

  if Code.ensure_compiled?(Money) do
    @doc """
    Generate Map of payment parameters.

    This function is only present, if the optional `money` package is installed.

    ### Examples

        iex> Application.put_env(:datatrans_helper, :merchant_id, "73452")
        iex> Application.put_env(:datatrans_helper, :sign1_hmac_key, "your_key")
        iex> DatatransHelper.generate_payment_info(Money.new(7_20, :CHF), "a5e511e9-7334-44c2-be21-cef964091739")
        %{amount: 7_20, currency: "CHF", merchant_id: "73452",
         refno: "a5e511e9-7334-44c2-be21-cef964091739",
         sign: "2A28243478E60BF7CC5D418D99A00287173DA3963AA5B3459830DBDDB86EB648"}

    """
    @spec generate_payment_info(Money.t, String.t) :: datatrans_payment_request
    def generate_payment_info(%Money{amount: amount, currency: currency}, reference) when amount > 0 do
      sign %{
        merchant_id: get_merchant_id(),
        amount: amount,
        currency: Atom.to_string(currency),
        refno: reference
      }
    end
  end

  @spec sign(%{merchant_id: String.t, amount: non_neg_integer, currency: String.t, refno: String.t})
    :: %{merchant_id: String.t, amount: float, currency: String.t, refno: String.t, sign: String.t}
  defp sign(payment_information) do
    sign = Base.encode16 :crypto.hmac(:sha256, get_sign1_hmac_key(),
      payment_information[:merchant_id] <>
      Integer.to_string(payment_information[:amount]) <>
      payment_information[:currency] <>
      payment_information[:refno]
    )

    Map.put(payment_information, :sign, sign)
  end

  @spec get_sign1_hmac_key() :: String.t
  defp get_sign1_hmac_key, do: ConfigExt.fetch_env!(:datatrans_helper, :sign1_hmac_key)

  @spec get_merchant_id() :: String.t | integer
  defp get_merchant_id do
    merchant_id = ConfigExt.fetch_env!(:datatrans_helper, :merchant_id)
    if is_integer(merchant_id) do
      Integer.to_string(merchant_id)
    else
      merchant_id
    end
  end
end
