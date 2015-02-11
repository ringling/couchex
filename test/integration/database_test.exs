defmodule Integration.DatabaseTest do
  use ExUnit.Case
  use ShouldI, async: true

  @create_db_name "created_db"
  @existing_db_name "existing_db"
  @integration_test_db "couchex"
  @integration_test_rep_db "couchex_rep"
  @existing_doc_id "couchex"
  @existing_doc %{"key" => "value", "_id" => @existing_doc_id}

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
    :ok
  end

  with "database" do
    setup context do
      {:ok, db} = Couchex.open_db(TestHelper.server, @integration_test_db)
      Dict.put context, :db, db
    end

    should "have couchdb key", context do
      {:ok, info} = Couchex.db_info(context.db)
      assert info["db_name"] == @integration_test_db
    end

    should "return db url", context do
      assert @integration_test_db == Couchex.db_url(context.db)
    end

    should "compact database", context do
      assert :ok == Couchex.compact(context.db)
    end
  end

  with "server" do

    setup context do
      Dict.put context, :server, TestHelper.server
    end

    should "return :not_found when trying to delete not existing database", context do
      assert {:error, :not_found} == Couchex.delete_db(context.server, "not_existing")
    end

    should "delete existing database", context do
      db_name = "some_db"
      Couchex.create_db(context.server, db_name)
      assert {:ok, :db_deleted} == Couchex.delete_db(context.server, db_name)
    end

    should "create database", context do
      assert {:ok, {:db, _, @create_db_name, _ }} = Couchex.create_db(context.server, @create_db_name)
    end

    should "return true when database exists?", context do
      assert Couchex.db_exists?(context.server, @existing_db_name)
    end

    should "return false when database does not exists?", context do
      refute Couchex.db_exists?(context.server, "not_existing")
    end

    should "replicate database", context do
      rep_obj = %{source: @integration_test_db, target: @integration_test_rep_db, create_target: true}
      {:ok, resp} = Couchex.replicate(context.server, rep_obj)
      assert Map.has_key?(resp, "history")
      assert Couchex.db_exists?(context.server, @integration_test_rep_db)
    end

    should "replicate database continuous", context do
      rep_obj = %{source: @integration_test_db, target: @integration_test_rep_db, create_target: true , continuous: true}
      {:ok, resp} = Couchex.replicate(context.server, rep_obj)
      assert Map.has_key?(resp, "Date")
      assert Couchex.db_exists?(context.server, @integration_test_rep_db)
    end

  end

end
