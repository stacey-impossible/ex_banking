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

  @doc """
  Function decreases user’s balance in given currency by amount value.
  """
  @spec withdraw(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error,
             :wrong_arguments
             | :user_does_not_exist
             | :not_enough_money
             | :too_many_requests_to_user}
  def withdraw(user, amount, currency) do
    GenServer.call(ExBankingStack, {:withdraw, user, amount, currency})
  end

  @doc """
  Returns balance of the user in given format
  """
  @spec get_balance(user :: String.t(), currency :: String.t()) ::
          {:ok, balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def get_balance(user, currency) do
    GenServer.call(ExBankingStack, {:get_balance, user, currency})
  end
end
