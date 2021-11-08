defmodule ExBanking.Registry do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl true
  def init(:ok) do
    users = %{}
    {:ok, users}
  end
end
