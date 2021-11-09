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

  @doc """
  Function increases user’s balance in given currency by amount value.

  ## Examples

      iex> ExBanking.create_user("foobar")
      iex> ExBanking.deposit("foobar", 20, "RUB")
      {:ok, 20}

  """
  @spec deposit(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def deposit(user, amount, currency) do
    GenServer.call(ExBankingStack, {:deposit, user, amount, currency})
  end
end
