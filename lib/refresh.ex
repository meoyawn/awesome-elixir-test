defmodule GitHubWorker do
  use GenServer, restart: :transient

  @spec start_link(arg) :: :ignore | {:error, arg} | {:ok, pid} when arg: var
  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  @spec init(arg) :: {:ok, arg} when arg: var
  def init(arg) do
    {:ok, arg}
  end

  def handle_call({url, repo}, _caller, state) do
    {:reply, GitHubApi.fetch(repo, url), state}
  end
end

defmodule GitHubPool do
  use Supervisor

  @pool_id :github

  def submit(url, repo) do
    :poolboy.transaction(
      @pool_id,
      fn pid -> GenServer.call(pid, {url, repo}, :infinity) end,
      :infinity
    )
  end

  @spec start_link(arg) :: :ignore | {:error, arg} | {:ok, pid} when arg: var
  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg)
  end

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
  require Logger

  @spec start_link(arg) :: :ignore | {:error, arg} | {:ok, pid} when arg: var
  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  @spec init(arg) :: {:ok, arg} when arg: var
  def init(arg) do
    :ok = Logger.warn("First refresh")
    send(self(), :refresh)
    {:ok, arg}
  end

  @spec refresh(String.t(), String.t()) :: any
  def refresh(readme \\ Markdown.host(), api \\ GitHubApi.host()) do
    {cats, repos} = Markdown.fetch(readme)

    repos
    |> Enum.map(fn repo -> Task.async(fn -> GitHubPool.submit(api, repo) end) end)
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
    :ok = Logger.warn("Starting refresh")
    {:ok, pid} = Task.start(&refresh/0)
    Process.monitor(pid)
    {:noreply, state}
  end

  @hour 3600 * 1000

  def handle_info({:DOWN, _ref, :process, _pid, :normal}, state) do
    :ok = Logger.warn("Success. Next refresh in 24h")
    Process.send_after(self(), :refresh, 24 * @hour)
    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, _pid, _msg}, state) do
    :ok = Logger.warn("Failure. Next refresh in 1h")
    Process.send_after(self(), :refresh, 1 * @hour)
    {:noreply, state}
  end
end
