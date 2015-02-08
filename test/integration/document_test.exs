defmodule Integration.DocumentTest do
  use ExUnit.Case, async: true

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
    {:ok, resp_doc} = Couchex.save_doc(db, doc)
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
    {:ok, doc} = Couchex.open_doc(db, @existing_doc_id)
    assert doc["_id"] == @existing_doc_id
    assert doc["key"] == "value"
  end

  test "open not existing doc", %{db: db} do
    assert {:error, :not_found} == Couchex.open_doc(db, "not_existing_doc_id")
  end

  test "doc exists", %{db: db} do
    assert Couchex.doc_exists?(db, @existing_doc_id)
  end

  test "doc does not exist", %{db: db} do
    refute Couchex.doc_exists?(db, "not_existing_doc_id")
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
    {:ok, response} = Couchex.put_attachment(db, @existing_doc_id, attachment)

    assert response["id"] == @existing_doc_id
    assert  String.contains? response["rev"], "2-"
  end

  # test "delete attachment", %{db: db} do
  #   attachment_name = "file.txt"
  #   content_type = Couchex.MIME.type("txt") # => "text/plain"
  #   attachment = %{ name: attachment_name, data: "SOME DATA - HERE IT'S TEXT", content_type: content_type }
  #   Couchex.put_attachment(db, @existing_doc_id, attachment)

  #   IO.inspect Couchex.delete_attachment(db, @existing_doc_id, attachment_name)
  # end


end