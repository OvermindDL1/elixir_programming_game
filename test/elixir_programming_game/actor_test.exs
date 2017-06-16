defmodule ElixirProgrammingGameTest.ActorTest do
  use ExUnit.Case, async: false # true
  doctest ElixirProgrammingGame.Actor
  alias ElixirProgrammingGame.Actor

  setup do
    {:ok, actor} = Actor.start_link(save_to_pid: self())
    {:ok, actor: actor}
  end


  test "initializes and stops properly", %{actor: actor} do
    assert true = Process.alive?(actor)
    id = Actor.get_id(actor)
    Actor.stop(actor)
    assert_receive({:actor_state, :request, %{id: ^id}=state})
    assert %{} = state
  end

  test "set event code and run event - init", %{actor: actor} do
    Actor.set_event_code(actor, "init", """
      state
    """)
    Actor.send_event(actor, "init", %{})
    Actor.get_id(actor) # Synchronize
  end

  test "set event code and run event - init - with cmd", %{actor: actor} do
    Actor.set_event_code(actor, "init", """
      # cmd = Actor.log("Tester")
      cmd = Actor.save()
      {[cmd], state}
    """)
    Actor.send_event(actor, "init", %{})
    id = Actor.get_id(actor) # Synchronize
    assert_receive({:actor_state, :request, %{id: ^id}=state})
    assert %{} = state
  end
end
