defmodule Integration.DatabaseTest do
  use ExUnit.Case, async: false

  @create_db_name "created_db"
  @existing_db_name "existing_db"
  @integration_test_db "couchex"
  @integration_test_rep_db "couchex_rep"
  @existing_doc_id "couchex"
  @existing_doc %{"key" => "value", "_id" => @existing_doc_id}
  @design_doc %{
    "_id" => "_design/lists",
    "language": "javascript",
    "views": %{
       "byKey": %{
          "map": "function(doc) {\n  emit(doc.key, doc);\n}"
       }
     }
   }



  setup_all do
    # Delete old integration test db
    Couchex.delete_db(TestHelper.server, @create_db_name)
    Couchex.delete_db(TestHelper.server, @integration_test_db)
    Couchex.delete_db(TestHelper.server, @integration_test_rep_db)
    # Create integration test db
    Couchex.create_db(TestHelper.server, @existing_db_name)
    Couchex.create_db(TestHelper.server, @integration_test_db)
    {:ok, db} = Couchex.open_db(TestHelper.server, @integration_test_db)
    Couchex.save_doc(db, @existing_doc)
    Couchex.save_doc(db, @design_doc)
    :ok
  end

  setup do
    {:ok, db} = Couchex.open_db(TestHelper.server, @integration_test_db)
    {:ok, db: db, server: TestHelper.server}
  end

  test "db info has couchdb key", %{db: db} do
    {:ok, info} = Couchex.db_info(db)
    assert info["db_name"] == @integration_test_db
  end

  test "delete not existing database", %{server: server} do
    assert {:error, :not_found} == Couchex.delete_db(server, "not_existing")
  end

  test "delete existing database by name", %{server: server} do
    db_name = "some_db"
    Couchex.create_db(server, db_name)
    assert {:ok, :db_deleted} == Couchex.delete_db(server, db_name)
  end

  test "delete existing databasee", %{server: server} do
    db_name = "some_db_1"
    {:ok, db} = Couchex.create_db(server, db_name)
    assert {:ok, :db_deleted} == Couchex.delete_db(db)
  end

  test "create database", %{server: server} do
    assert {:ok, {:db, _, @create_db_name, _ }} = Couchex.create_db(server, @create_db_name)
  end

  test "database exists? true", %{server: server} do
    assert Couchex.db_exists?(server, @existing_db_name)
  end

  test "database exists? false", %{server: server} do
    refute Couchex.db_exists?(server, "not_existing")
  end

  test "compact database", %{db: db} do
    {:db, server, db_name, _opts} = db
    assert Couchex.db_exists?(server, db_name)
    assert :ok == Couchex.compact(db)
  end

  test "compact view index", %{db: db} do
    {:db, server, db_name, _opts} = db
    design_name = "lists"
    assert Couchex.db_exists?(server, db_name)
    assert :ok == Couchex.compact(db, design_name)
  end

  test "replicate database", %{server: server} do
    rep_obj = %{source: @integration_test_db, target: @integration_test_rep_db, create_target: true}
    {:ok, resp} = Couchex.replicate(server, rep_obj)
    assert Map.has_key?(resp, "history")
    assert Couchex.db_exists?(server, @integration_test_rep_db)
  end

  # test "replicate database continuous", %{server: server} do
  #   rep_obj = %{source: @integration_test_db, target: @integration_test_rep_db, create_target: true , continuous: true}
  #   {:ok, resp} = Couchex.replicate(server, rep_obj)
  #   assert Map.has_key?(resp, "Date")
  #   assert Couchex.db_exists?(server, @integration_test_rep_db)
  # end

  test "follow change", %{db: db} do
    {:ok, _stream_ref} = Couchex.follow(db, [:continuous, :heartbeat, :include_docs])
    {:ok, _doc} = Couchex.save_doc(db, %{foo: "bar"})

    # "couchex doc"
    receive do
      {_ref, {:change, change}} -> assert seq(change) == "1"
    end

    # "design doc"
    receive do
      {_ref, {:change, change}} -> assert seq(change) == "2"
    end

    # "our doc"
    receive do
      {_ref, {:change, change}} ->
        [_id, _rev, doc] = change |> Mapper.list_to_map |> Map.get("doc")
        assert doc == %{"foo" => "bar"}
        assert seq(change) == "3"
    end

  end

  def seq(change) do
    change = change |> Mapper.list_to_map
    [seq | _] = String.split(change["seq"], "-")
    seq
  end

end
