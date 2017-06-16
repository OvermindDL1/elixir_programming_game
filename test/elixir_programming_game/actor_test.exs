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

  test "Blah" do
  end
end
