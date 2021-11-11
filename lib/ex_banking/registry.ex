defmodule ExBanking.Registry do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: ExBankingStack)
  end

  @impl true
  def init(users) do
    {:ok, users}
  end

  @impl true
  def handle_call({:create, user}, _from, users) when is_binary(user) do
    case users do
      %{^user => _} -> {:reply, {:error, :user_already_exists}, users}
      _ -> {:reply, :ok, Map.put(users, user, %{})}
    end
  end

  @impl true
  def handle_call({:deposit, user, amount, currency}, _from, users)
      when is_binary(user) and is_binary(currency) and is_number(amount) and amount >= 0 do
    with {:ok, balance} <- check_user(users, user),
         {:ok, new_balance} <- deposit(balance, currency, amount) do
      {:reply, {:ok, new_balance[currency]}, Map.update!(users, user, fn _ -> new_balance end)}
    else
      error -> {:reply, error, users}
    end
  end

  @impl true
  def handle_call({:withdraw, user, amount, currency}, _from, users)
      when is_binary(user) and is_binary(currency) and is_number(amount) and amount >= 0 do
    with {:ok, balance} <- check_user(users, user),
         {:ok, new_balance} <- withdraw(balance, currency, amount) do
      {:reply, {:ok, Map.get(new_balance, currency, 0)},
       Map.update!(users, user, fn _ -> new_balance end)}
    else
      error -> {:reply, error, users}
    end
  end

  @impl true
  def handle_call({:get_balance, user, currency}, _from, users)
      when is_binary(user) and is_binary(currency) do
    case check_user(users, user) do
      {:ok, balance} -> {:reply, {:ok, Map.get(balance, currency, 0)}, users}
      error -> {:reply, error, users}
    end
  end

  @impl true
  def handle_call(_, _, users) do
    {:reply, {:error, :wrong_arguments}, users}
  end

  defp check_user(users, user) do
    case users do
      %{^user => balance} -> {:ok, balance}
      _ -> {:error, :user_does_not_exist}
    end
  end

  defp deposit(balance, currency, amount) do
    {:ok, Map.update(balance, currency, amount, &(&1 + amount))}
  end

  defp withdraw(balance, _currency, 0) do
    {:ok, balance}
  end

  defp withdraw(balance, currency, amount) do
    if is_nil(balance[currency]) or balance[currency] < amount do
      {:error, :not_enough_money}
    else
      {:ok, Map.update(balance, currency, amount, &(&1 - amount))}
    end
  end
end
