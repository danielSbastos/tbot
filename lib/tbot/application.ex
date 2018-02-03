# credo:disable-for-this-file Credo.Check.Design.AliasUsage
# credo:disable-for-next-line Credo.Check.Readability.ModuleDoc
defmodule Tbot.Application do
  use Application

  import Supervisor.Spec

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(TbotWeb.Endpoint, []),
      supervisor(Task.Supervisor, [[name: Tbot.TaskSupervisor, restart: :transient]]),
    ] ++ redis_pool()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tbot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TbotWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp redis_pool() do
    pool_size = Application.get_env(:tbot, :redis_pool_size)
    redix_workers = for i <- 0..(pool_size - 1) do
      worker(Redix, [[], [name: :"redix_#{i}"]], id: {Redix, i})
    end
  end
end
