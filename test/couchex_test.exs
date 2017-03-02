defmodule CouchexTest do
  use ExUnit.Case, async: true
  import Couchex
  require Logger

  @moduletag timeout: 60000*60

  test "test" do
    server = server_connection("http://localhost:5984", [{:basic_auth, {"test", "test"}}])
    {:ok, _db} = open_db(server, "xxx", [])
    # IO.inspect delete_db(db)

    # {:ok, stream_ref} = follow(db, [:continuous, :heartbeat, {:timeout, 20000}])
    # changes_fun(stream_ref)
  end

  def changes_fun(stream_ref) do
   receive do
     {_stream_ref, {:done, last_seq}} ->
       Logger.info "Stopped at seq: #{inspect last_seq}"
       :ok
     {_stream_ref, {:change, change}} ->
       Logger.info "Change: #{inspect change}"
       changes_fun(stream_ref)
     {_stream_ref, error}->
       Logger.error "#{inspect error}"
    msg ->
       Logger.warn "#{inspect msg}"
   end
  end


end
