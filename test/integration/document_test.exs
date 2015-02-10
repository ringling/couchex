defmodule Integration.DocumentTest do
  use ExUnit.Case, async: true

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

  setup do
    {:ok, db} = Couchex.open_db(TestHelper.server, @integration_test_db)
    {:ok, db: db, server: TestHelper.server}
  end

  test "create new doc without id", %{db: db} do
    doc = %{"key" => "value"}
    {:ok, resp_doc} = Couchex.save_doc(db, doc)
    assert resp_doc["key"] == "value"
  end

  test "create new doc with id", %{db: db} do
    doc_id = "1_FIRST_ID"
    doc = %{"key" => "value", "_id" => doc_id}
    {:ok, resp_doc} = Couchex.save_doc(db, doc)
    assert resp_doc["_id"] == doc_id
    assert resp_doc["key"] == "value"
  end

  test "creating doc with existing id should fail", %{db: db} do
    doc_id = "EXISTING_ID"
    doc = %{"key" => "value", "_id" => doc_id}
    {:ok, _} = Couchex.save_doc(db, doc)
    assert {:error, :conflict} == Couchex.save_doc(db, doc)
  end

  test "update doc", %{db: db} do
    doc_id = "EXISTING_ID_2"
    doc = %{"key" => "value", "_id" => doc_id}
    {:ok, resp_doc} = Couchex.save_doc(db, doc)
    doc = %{"key" => "value", "_id" => doc_id, "_rev" => resp_doc["_rev"]}
    {:ok, update} = Couchex.save_doc(db, doc)
    assert update["_id"] == doc_id
  end

  test "open doc", %{db: db} do
    {:ok, doc} = Couchex.open_doc(db, %{id: @existing_doc_id})
    assert doc["_id"] == @existing_doc_id
    assert doc["key"] == "value"
  end

  test "open not existing doc", %{db: db} do
    assert {:error, :not_found} == Couchex.open_doc(db, %{id: "not_existing_doc_id"})
  end

  test "doc exists", %{db: db} do
    assert Couchex.doc_exists?(db, @existing_doc_id)
  end

  test "doc does not exist", %{db: db} do
    refute Couchex.doc_exists?(db, "not_existing_doc_id")
  end

  test "all docs" do
    {:ok, db} = Couchex.open_db(TestHelper.server, @all_docs_db)
    TestHelper.insert_doc(db, %{"key" => "value", "_id" => "doc_id_1"})
    TestHelper.insert_doc(db, %{"key" => "value", "_id" => "doc_id_2"})
    resp = Couchex.all(db) |> hd
    assert resp["doc"]["_id"] == "doc_id_1"
  end

  test "delete doc", %{db: db} do
    doc = %{"key" => "value", "_id" => "DELETE_DOC"}
    {:ok, resp_doc} = Couchex.save_doc(db, doc)
    {:ok, resp} = Couchex.delete_doc(db, %{id: resp_doc["_id"], rev: resp_doc["_rev"]})
    assert resp["ok"]
    refute Couchex.doc_exists?(db, resp_doc["_id"])
  end

  test "lookup_doc_rev", %{db: db} do
    doc_id = "SOME_ID"
    doc = %{"key" => "value", "_id" => doc_id}
    {:ok, resp_doc} = Couchex.save_doc(db, doc)
    {:ok, rev} = Couchex.lookup_doc_rev(db, doc_id)
    assert rev == resp_doc["_rev"]
  end

  test "put attachment", %{db: db} do
    content_type = Couchex.MIME.type("txt") # => "text/plain"
    attachment = %{ name: "file.txt", data: "SOME DATA - HERE IT'S TEXT", content_type: content_type }
    {:ok, response} = Couchex.put_attachment(db, %{id: @existing_doc_id}, attachment)

    assert response["id"] == @existing_doc_id
    assert  String.contains? response["rev"], "2-"
  end

  test "delete attachment without doc revision", %{db: db} do
    doc_id = "SOME_ID_ATT_1"
    TestHelper.insert_doc(db, %{"key" => "value", "_id" => doc_id})
    TestHelper.put_txt_attachement(db, doc_id, "file.txt")

    {:ok, response} = Couchex.delete_attachment(db, %{id: doc_id}, "file.txt")
    assert response["id"] == doc_id
    assert  String.contains? response["rev"], "3-"
  end

  test "delete attachment with doc revision", %{db: db} do
    doc_id = "SOME_ID_ATT_2"
    TestHelper.insert_doc(db, %{"key" => "value", "_id" => doc_id})
    {:ok, doc_info} = TestHelper.put_txt_attachement(db, doc_id, "file2.txt")

    {:ok, response} = Couchex.delete_attachment(db, %{id: doc_info["id"], rev: doc_info["rev"]}, "file2.txt")
    assert response["id"] == doc_id
    assert String.contains? response["rev"], "3-"
  end

end
