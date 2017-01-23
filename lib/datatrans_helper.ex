defmodule DatatransHelper do
  @moduledoc """
  Small Helper Function to sign Datatrans Request Parameters
  """

  @doc """
  Generate Map of payment parameters.

  ### Examples

      iex> Application.put_env(:datatrans_helper, :merchant_id, "73452")
      iex> Application.put_env(:datatrans_helper, :hmac_key, "your_key")
      iex> DatatransHelper.generate_payment_info(7.2, "CHF", "a5e511e9-7334-44c2-be21-cef964091739")
      %{amount: 7.2, currency: "CHF", merchant_id: "73452",
       refno: "a5e511e9-7334-44c2-be21-cef964091739",
       sign: "1EC9627CC7BA2E58251656BD500672BB6C5509FD569BB31737EE381C56CFE785"}

  """
  @spec generate_payment_info(float, String.t, String.t)
    :: %{merchant_id: String.t, amount: float, currency: String.t, refno: String.t, sign: String.t}
  def generate_payment_info(amount, currency, reference) do
    sign %{
      merchant_id: get_merchant_id(),
      amount: amount,
      currency: currency,
      refno: reference
    }
  end

  @spec sign(%{merchant_id: String.t, amount: float, currency: String.t, refno: String.t})
    :: %{merchant_id: String.t, amount: float, currency: String.t, refno: String.t, sign: String.t}
  defp sign(payment_information) do
    sign = Base.encode16 :crypto.hmac(:sha256, get_hmac_key(),
      payment_information[:merchant_id] <>
      Float.to_string(payment_information[:amount]) <>
      payment_information[:currency] <>
      payment_information[:refno]
    )

    Map.put(payment_information, :sign, sign)
  end

  @spec get_hmac_key() :: String.t
  defp get_hmac_key, do: ConfigExt.fetch_env!(:datatrans_helper, :hmac_key)

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
