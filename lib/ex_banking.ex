defmodule ExBanking do
  @moduledoc """
  Documentation for `ExBanking`.
  """

  @doc """
  Function creates new user in the system.
  Username must be unique string.

  ## Examples

      iex> ExBanking.create_user("foo")
      :ok

      iex> ExBanking.create_user("bar")
      iex> ExBanking.create_user("bar")
      {:error, :user_already_exists}

      iex> ExBanking.create_user(:bar)
      {:error, :wrong_arguments}

  """

  @spec create_user(user :: String.t()) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(user) do
    GenServer.call(ExBankingStack, {:create, user})
  end
end
