defmodule Server do
  defmacro __using__(_opts) do
    quote do
      def init(state) do
        {:ok, state}
      end
      def handle_cast(_data, state) do
        {:noreply, state}
      end
      def handle_call(_data, _from, state) do
        {:noreply, state}
      end
      def handle_info(_data, state) do
        {:noreply, state}
      end
      defoverridable [init: 1]
      defoverridable [handle_cast: 2]
      defoverridable [handle_call: 3]
      defoverridable [handle_info: 2]
    end
  end

  def start(module, state) do
    pid = \
    __MODULE__
    |> Kernel.spawn(:init, [module, state])
    {:ok, pid}
  end
  def start_link(module, state) do
    pid = \
    __MODULE__
    |> Kernel.spawn_link(:init, [module, state])
    {:ok, pid}
  end

  def cast(pid, data) do
    message = {:cast, data}
    Kernel.send(pid, message)
    :ok
  end

  def call(pid, data, timeout \\ 5000) do
    message = {:call, data, self()}
    Kernel.send(pid, message)

    receive do
      {:reply, reply} -> reply
    after
      timeout -> :error
    end
  end

  def init(module, state) do
    state = %{
      public: state,
      module: module
    }
    state.module.init(state)
    |> case do
      {:ok, state} ->
        loop(state)
    end
  end

  defp loop(state) do
    public = \
    receive do
      {:cast, data} ->
        handle_cast(data, state)
      {:call, data, from} ->
        handle_call(data, from, state)
      other ->
        handle_info(other, state)
    end
    %{state | public: public}
    |> loop
  end

  defp handle_cast(data, state) do
    state.module.handle_cast(data, state.public)
    |> case do
      {:noreply, state} ->
        state
    end
  end

  defp handle_call(data, from, state) do
    state.module.handle_call(data, from, state.public)
    |> case do
      {:reply, reply, state} ->
        message = {:reply, reply}
        Kernel.send(from, message)
        state
    end
  end

  defp handle_info(data, state) do
    state.module.handle_info(data, state.public)
    |> case do
      {:noreply, state} ->
        state
    end
  end
end
