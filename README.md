# Server

An Elixir [GenServer](https://hexdocs.pm/elixir/GenServer.html) mockup.

```elixir
defmodule Test do
  use Server

  def start_link do
    Server.start_link __MODULE__, :state
  end

  def handle_cast(data, state) do
    IO.inspect {:cast, data}
    {:noreply, state}
  end

  def handle_call(data, from, state) do
    IO.inspect {:call, data, from}
    {:reply, :replied!, state}
  end

  def handle_info(event, state) do
    IO.inspect {:info, event}
    {:noreply, state}
  end
end
```
