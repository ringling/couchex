defmodule Integration.MangoTest do
  use ExUnit.Case, async: false

  @integration_test_db "couchex"
  @existing_doc_id "couchex"
  @existing_doc %{"key" => "value", "_id" => @existing_doc_id}

  setup_all do
    Couchex.delete_db(TestHelper.server, @integration_test_db)
    # Create integration test dbs
    Couchex.create_db(TestHelper.server, @integration_test_db)
    {:ok, db} = Couchex.open_db(TestHelper.server, @integration_test_db)
    Couchex.save_doc(db, @existing_doc)
    :ok
  end

  setup do
    {:ok, db} = Couchex.open_db(TestHelper.server, @integration_test_db)
    {:ok, db: db, server: TestHelper.server}
  end

  test "should find all docs with mango query", %{db: db} do
    query = %{
      "selector": %{
        "_id": %{
          "$gt": nil
        }
      }
    }

    docs = Couchex.find(db, query)
    doc_ids = Enum.map(docs, &(&1["_id"]))
    refute [] == docs
    assert Enum.any?(doc_ids, fn(x) -> x == @existing_doc_id end)
  end

  test "should find specific doc with mango query", %{db: db} do
    query = %{
      "selector": %{
        "_id": %{
          "$eq": @existing_doc_id
        }
      }
    }

    docs = Couchex.find(db, query)
    refute [] == docs
    [doc] = docs
    assert doc["_id"] == @existing_doc_id
    assert doc["key"] == "value"
  end


end