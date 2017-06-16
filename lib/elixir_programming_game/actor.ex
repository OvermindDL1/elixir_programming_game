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


  ## Server Callbacks

  def init(opts) do
    state = %{
      id: opts[:id] || make_ref(),
      save_to_pid: opts[:save_to_pid],
    }
    {:ok, state}
  end


  def handle_call(:get_id, _from, %{id: id} = state) do
    {:reply, id, state}
  end
  def handle_call(request, from, state) do
    Logger.error("Invalid call received:  #{inspect {request, from, state}}")
    {:noreply, state}
  end


  def handle_cast({:stop, do_send_state}, state) do
    if do_send_state, do: state = _send_state(state)
      Logger.error("Blargh:  #{inspect state}")
    {:stop, :normal, state}
  end
  def handle_cast(:send_state, state) do
    state = _send_state(state)
    {:noreply, state}
  end
  def handle_cast(request, state) do
    Logger.error("Invalid cast received:  #{inspect {request, state}}")
    {:noreply, state}
  end


  # def handle_info(request, state) do
  #   Logger.error("Invalid cast received:  #{inspect {request, state}}")
  # end


  defp _send_state(%{save_to_pid: pid} = state) when is_pid(pid) do
    send(pid, {:actor_state, :request, state})
    state
  end
  defp _send_state(state), do: state


end
