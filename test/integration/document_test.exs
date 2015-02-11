defmodule Integration.DocumentTest do
  use ExUnit.Case
  use ShouldI, async: true

  @create_db_name "created_db"
  @existing_db_name "existing_db"
  @all_docs_db "all_docs_db"
  @integration_test_db "couchex"
  @integration_test_rep_db "couchex_rep"
  @existing_doc_id "couchex"
  @existing_doc %{"key" => "value", "_id" => @existing_doc_id}

  setup_all do
    # Delete old integration test dbs
    Couchex.delete_db(TestHelper.server, @create_db_name)
    Couchex.delete_db(TestHelper.server, @all_docs_db)
    Couchex.delete_db(TestHelper.server, @integration_test_db)
    Couchex.delete_db(TestHelper.server, @integration_test_rep_db)
    # Create integration test dbs
    Couchex.create_db(TestHelper.server, @existing_db_name)
    Couchex.create_db(TestHelper.server, @integration_test_db)
    Couchex.create_db(TestHelper.server, @all_docs_db)
    {:ok, db} = Couchex.open_db(TestHelper.server, @integration_test_db)
    Couchex.save_doc(db, @existing_doc)
    :ok
  end

  with "database" do

    setup context do
      {:ok, db} = Couchex.open_db(TestHelper.server, @integration_test_db)
      Dict.put context, :db, db
    end

    should "create new doc without id", context do
      doc = %{"key" => "value"}
      {:ok, resp_doc} = Couchex.save_doc(context.db, doc)
      assert resp_doc["key"] == "value"
    end

    should "create new doc with id", context do
      doc_id = "1_FIRST_ID"
      doc = %{"key" => "value", "_id" => doc_id}
      {:ok, resp_doc} = Couchex.save_doc(context.db, doc)
      assert resp_doc["_id"] == doc_id
      assert resp_doc["key"] == "value"
    end

    should "creating doc with existing id should fail", context do
      doc_id = "EXISTING_ID"
      doc = %{"key" => "value", "_id" => doc_id}
      {:ok, _} = Couchex.save_doc(context.db, doc)
      assert {:error, :conflict} == Couchex.save_doc(context.db, doc)
    end

    should "update doc", context do
      doc_id = "EXISTING_ID_2"
      doc = %{"key" => "value", "_id" => doc_id}
      {:ok, resp_doc} = Couchex.save_doc(context.db, doc)
      doc = %{"key" => "value", "_id" => doc_id, "_rev" => resp_doc["_rev"]}
      {:ok, update} = Couchex.save_doc(context.db, doc)
      assert update["_id"] == doc_id
    end

    should "open doc", context do
      {:ok, doc} = Couchex.open_doc(context.db, %{id: @existing_doc_id})
      assert doc["_id"] == @existing_doc_id
      assert doc["key"] == "value"
    end

    should "open not existing doc", context do
      assert {:error, :not_found} == Couchex.open_doc(context.db, %{id: "not_existing_doc_id"})
    end

    should "doc exists", context do
      assert Couchex.doc_exists?(context.db, @existing_doc_id)
    end

    should "doc does not exist", context do
      refute Couchex.doc_exists?(context.db, "not_existing_doc_id")
    end

    should "all docs" do
      {:ok, db} = Couchex.open_db(TestHelper.server, @all_docs_db)
      TestHelper.insert_doc(db, %{"key" => "value", "_id" => "doc_id_1"})
      TestHelper.insert_doc(db, %{"key" => "value", "_id" => "doc_id_2"})
      resp = Couchex.all(db) |> hd
      assert resp["doc"]["_id"] == "doc_id_1"
    end

    should "delete doc", context do
      doc = %{"key" => "value", "_id" => "DELETE_DOC"}
      {:ok, resp_doc} = Couchex.save_doc(context.db, doc)
      {:ok, resp} = Couchex.delete_doc(context.db, %{id: resp_doc["_id"], rev: resp_doc["_rev"]})
      assert resp["ok"]
      refute Couchex.doc_exists?(context.db, resp_doc["_id"])
    end

    should "lookup_doc_rev", context do
      doc_id = "SOME_ID"
      doc = %{"key" => "value", "_id" => doc_id}
      {:ok, resp_doc} = Couchex.save_doc(context.db, doc)
      {:ok, rev} = Couchex.lookup_doc_rev(context.db, doc_id)
      assert rev == resp_doc["_rev"]
    end

    should "put attachment", context do
      content_type = Couchex.MIME.type("txt") # => "text/plain"
      attachment = %{ name: "file.txt", data: "SOME DATA - HERE IT'S TEXT", content_type: content_type }
      {:ok, response} = Couchex.put_attachment(context.db, %{id: @existing_doc_id}, attachment)

      assert response["id"] == @existing_doc_id
      assert  String.contains? response["rev"], "2-"
    end

    should "delete attachment without doc revision", context do
      doc_id = "SOME_ID_ATT_1"
      TestHelper.insert_doc(context.db, %{"key" => "value", "_id" => doc_id})
      TestHelper.put_txt_attachement(context.db, doc_id, "file.txt")

      {:ok, response} = Couchex.delete_attachment(context.db, %{id: doc_id}, "file.txt")
      assert response["id"] == doc_id
      assert  String.contains? response["rev"], "3-"
    end

    should "delete attachment with doc revision", context do
      doc_id = "SOME_ID_ATT_2"
      TestHelper.insert_doc(context.db, %{"key" => "value", "_id" => doc_id})
      {:ok, doc_info} = TestHelper.put_txt_attachement(context.db, doc_id, "file2.txt")

      {:ok, response} = Couchex.delete_attachment(context.db, %{id: doc_info["id"], rev: doc_info["rev"]}, "file2.txt")
      assert response["id"] == doc_id
      assert String.contains? response["rev"], "3-"
    end
  end

end
