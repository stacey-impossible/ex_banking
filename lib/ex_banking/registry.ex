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
      _ -> {:reply, :ok, Map.put_new(users, user, %{})}
    end
  end

  @impl true
  def handle_call({:create, _user}, _from, users) do
    {:reply, {:error, :wrong_arguments}, users}
  end

  @impl true
  def handle_call({:deposit, user, amount, currency}, _from, users)
      when is_binary(user) and is_binary(currency) and is_number(amount) and amount >= 0 do
    case users do
      %{^user => money} -> {:reply, {:ok, amount}, users}
      _ -> {:reply, {:error, :user_does_not_exist}, users}
    end
  end

  @impl true
  def handle_call({:deposit, _user, _amount, _currency}, _from, users) do
    {:reply, {:error, :wrong_arguments}, users}
  end
end
