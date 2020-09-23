defmodule Runner do
  use GenServer
  require Logger

  def start_link(_) do
    Logger.info("Up and running.")
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    RegistryCleaner.main()
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, Lib.env(:run_every) * 1000)
  end
end
