defmodule ElixirProgrammingGame.Actor do
  @moduledoc """
  Documentation for ElixirProgrammingGame.Actor.
  """

  use GenServer
  require Logger


  ## Client API


  @doc """
  Starts this Actor
  """
  def start_link(opts \\ %{}) do
    GenServer.start_link(__MODULE__, opts, [])
  end


  @doc """
  Stops this actor and optionally returns the state for serialization out atomically
  """
  def stop(actor, return_state \\ true)
  def stop(actor, return_state), do: GenServer.cast(actor, {:stop, return_state})


  @doc """
  Returns the unique ID of thie Actor
  """
  def get_id(actor) do
    GenServer.call(actor, :get_id)
  end


  @doc """
  Have Actor send it's state now
  """
  def send_state(actor) do
    GenServer.cast(actor, :send_state)
  end


  @doc """
  Set the code that runs on an event
  """
  def set_event_code(actor, event, code) when is_binary(event) do
    GenServer.cast(actor, {:set_event_code, event, code})
  end


  @doc """
  Send an event
  """
  def send_event(actor, event, msg) when is_binary(event) do
    GenServer.cast(actor, {:send_event, event, msg})
  end


  ## Server Callbacks

  def init(opts) do
    state = %{
      id: opts[:id] || make_ref(),
      save_to_pid: opts[:save_to_pid],
      event_handlers: %{},
      cache: %{
        event_cbs: %{},
      }
    }
    {:ok, state}
  end


  def handle_call(:get_id, _from, %{id: id} = state) do
    {:reply, id, state}
  end
  # def handle_call(request, from, state) do
  #   Logger.error("Invalid call received:  #{inspect {request, from, state}}")
  #   {:noreply, state}
  # end


  def handle_cast({:stop, do_send_state}, state) do
    if do_send_state, do: state = _send_state(state)
    {:stop, :normal, state}
  end
  def handle_cast(:send_state, state) do
    state = _send_state(state)
    {:noreply, state}
  end
  def handle_cast({:set_event_code, event, code}, state) do
    {:ok, state} = _set_event_code(event, code, state)
    {:noreply, state}
  end
  def handle_cast({:send_event, event, msg}, state) do
    {:ok, state} = _send_event(event, msg, state)
    {:noreply, state}
  end
  # def handle_cast(request, state) do
  #   Logger.error("Invalid cast received:  #{inspect {request, state}}")
  #   {:noreply, state}
  # end


  # def handle_info(request, state) do
  #   Logger.error("Invalid cast received:  #{inspect {request, state}}")
  # end


  defp _send_state(%{save_to_pid: pid} = state) when is_pid(pid) do
    send(pid, {:actor_state, :request, Map.delete(state, :cache)})
    state
  end
  defp _send_state(state), do: state



  defp _set_event_code(event, code, %{event_handlers: event_handlers, cache: cache}=state) do
    case SafeScript.safe_compile_of_input_block(code, [:evt]) do
      {:error, reason} -> {:error, reason}
      {:ok, fun} ->
        event_cbs = Map.put(cache.event_cbs, event, fun)
        cache = %{cache | event_cbs: event_cbs}
        event_handlers = Map.put(event_handlers, event, code)
        {:ok, %{state | event_handlers: event_handlers, cache: cache}}
    end
  end


  defp _send_event(event, msg, %{cache: %{event_cbs: event_cbs}}=state) do
    case event_cbs[event] do
      nil -> {:ok, state}
      cb ->
        try do
          result = cb.(msg)
          state = _process_cmd(result, state)
          {:ok, state}
        catch
          :error, reason -> {:error, reason}
          e, r -> {:error, {e, r}}
        end
    end
  end
  defp _send_event(_event, _msg, state), do: {:ok, state}



  defp _process_cmd(cmd, state)
  defp _process_cmd([], state), do: state
  defp _process_cmd(cmd, state) do
    Logger.error("Unhandled cmd of `#{inspect cmd}` with state of:  #{inspect state}")
    state
  end


end
