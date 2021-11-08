defmodule ExBanking.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [ExBanking.Registry]

    opts = [strategy: :one_for_all, name: ExBanking.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
