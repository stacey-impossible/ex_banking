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
    with {:ok, _} <- check_queue(),
         {:ok, balance} <- check_user(users, user),
         {:ok, new_balance} <- deposit(balance, currency, amount) do
      {:reply, {:ok, new_balance[currency]}, Map.update!(users, user, fn _ -> new_balance end)}
    else
      error -> {:reply, error, users}
    end
  end

  @impl true
  def handle_call({:withdraw, user, amount, currency}, _from, users)
      when is_binary(user) and is_binary(currency) and is_number(amount) and amount >= 0 do
    with {:ok, _} <- check_queue(),
         {:ok, balance} <- check_user(users, user),
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
    with {:ok, _} <- check_queue(),
         {:ok, balance} <- check_user(users, user) do
      {:reply, {:ok, Map.get(balance, currency, 0)}, users}
    else
      error -> {:reply, error, users}
    end
  end

  @impl true
  def handle_call({:send, from_user, to_user, amount, currency}, _from, users)
      when is_binary(from_user) and is_binary(to_user) and is_binary(currency) and
             is_number(amount) and amount >= 0 do
    with {:ok, _} <- check_queue(),
         {:ok, from_balance, to_balance} <- check_users(users, from_user, to_user),
         {:ok, new_from_balance} <- withdraw(from_balance, currency, amount),
         {:ok, new_to_balance} <- deposit(to_balance, currency, amount) do
      users =
        users
        |> Map.update!(from_user, fn _ -> new_from_balance end)
        |> Map.update!(to_user, fn _ -> new_to_balance end)

      {:reply,
       {:ok, Map.get(new_from_balance, currency, 0), Map.get(new_to_balance, currency, 0)}, users}
    else
      error -> {:reply, error, users}
    end
  end

  @impl true
  def handle_call(_, _, users) do
    {:reply, {:error, :wrong_arguments}, users}
  end

  defp check_queue do
    queue = Process.info(self())[:message_queue_len]

    if queue > 10 do
      {:ok, queue}
    else
      {:error, :too_many_requests_to_user}
    end
  end

  defp check_user(users, user) do
    case users do
      %{^user => balance} -> {:ok, balance}
      _ -> {:error, :user_does_not_exist}
    end
  end

  defp check_users(users, from_user, to_user) do
    case users do
      %{^from_user => from_balance, ^to_user => to_balance} -> {:ok, from_balance, to_balance}
      %{^to_user => _} -> {:error, :sender_does_not_exist}
      _ -> {:error, :receiver_does_not_exist}
    end
  end

  defp deposit(balance, currency, amount) when is_float(amount) do
    {:ok, Map.update(balance, currency, amount, &Float.round(&1 + amount, 2))}
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
      {:ok, Map.update(balance, currency, amount, &substract_amount(&1, amount))}
    end
  end

  defp substract_amount(deposit, amount) when is_float(amount) do
    Float.round(deposit - amount, 2)
  end

  defp substract_amount(deposit, amount) do
    deposit - amount
  end
end
