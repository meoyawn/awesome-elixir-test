defmodule GitHubWorker do
  use GenServer, restart: :transient

  @spec start_link(arg) :: :ignore | {:error, arg} | {:ok, pid} when arg: var
  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  @impl true
  @spec init(arg) :: {:ok, arg} when arg: var
  def init(arg) do
    {:ok, arg}
  end

  @impl true
  @spec handle_call(MarkdownRepo.t(), any, state) :: {:reply, GitRepo.t() | :not_found, state}
        when state: var
  def handle_call(repo, _caller, state) do
    {:reply, GitHubApi.fetch(repo), state}
  end
end

defmodule GitHubPool do
  use Supervisor

  @pool_id :github

  @spec submit(MarkdownRepo.t()) :: GitRepo.t() | :not_found
  def submit(repo) do
    :poolboy.transaction(@pool_id, fn pid -> GenServer.call(pid, repo, :infinity) end, :infinity)
  end

  @spec start_link(arg) :: :ignore | {:error, arg} | {:ok, pid} when arg: var
  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg)
  end

  @impl true
  def init(_arg) do
    pool_options = [
      {:name, {:local, @pool_id}},
      {:worker_module, GitHubWorker},
      {:size, 0},
      {:max_overflow, 4}
    ]

    children = [
      :poolboy.child_spec(@pool_id, pool_options)
    ]

    supervise(children, strategy: :one_for_one)
  end
end

defmodule PeriodicRefresh do
  use GenServer, restart: :transient

  @spec start_link(arg) :: :ignore | {:error, arg} | {:ok, pid} when arg: var
  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  @spec init(arg) :: {:ok, arg} when arg: var
  def init(arg) do
    IO.puts("First refresh")
    send(self(), :refresh)
    {:ok, arg}
  end

  defp refresh do
    {cats, repos} = Markdown.fetch()

    repos
    |> Enum.map(fn repo -> Task.async(fn -> GitHubPool.submit(repo) end) end)
    |> Task.yield_many(:infinity)
    |> Enum.flat_map(fn {_task, {:ok, result}} ->
      case result do
        :not_found -> []
        x -> [x]
      end
    end)
    |> Database.insert_all(cats)
  end

  def handle_info(:refresh, state) do
    IO.puts("Starting refresh")
    {:ok, pid} = Task.start(&refresh/0)
    Process.monitor(pid)
    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, _pid, :normal}, state) do
    IO.puts("Success. Next refresh in 24h")
    Process.send_after(self(), :refresh, 24 * 3600 * 1000)
    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, _pid, _msg}, state) do
    IO.puts("Failure. Next refresh in 30m")
    Process.send_after(self(), :refresh, 30 * 60 * 1000)
    {:noreply, state}
  end
end
