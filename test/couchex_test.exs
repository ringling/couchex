defmodule CouchexTest do
  use ExUnit.Case, async: true


  test "save new doc" do
    doc_id = "18c359e463c37525e0ff484dcc0003b7"
    {:ok, db} = Couchex.open_db(server, "couchex")
    doc = %{"key" => "value", "_id" => doc_id}

  end

  test "test save" do

    doc_id = "18c359e463c37525e0ff484dcc0003b7"
    revision = "17-769046e9b813465fa7be51c4e270accf"

    doc = %{"key" => "value", "_id" => doc_id}
    doc = %{"key" => "value", "_id" => doc_id, "_rev" => revision}

    # {:ok, db} = Couchex.open_db(server, "couchex")


    # {:ok, {[doc,id,rev]}} = Couchex.save_doc(db, doc)

    # IO.inspect Couchex.open_doc(db, doc_id)

    # {:error, :conflict} = Couchex.save_doc(db, doc)

   #  {[{"key", "value"}, {"_id", doc_id},
   # {"_rev", "1-59414e77c768bc202142ac82c2f129de"}]}}

   #  IO.inspect Couchex.save_doc(db, doc)
    # IO.inspect doc

    # content_type = Couchex.MIME.type("txt") # => "text/plain"
    # attachment = %{ name: "file.txt", data: "SOME DATA - HERE IT'S TEXT", content_type: content_type }
    # {:ok, {[{"id", "18c359e463c37525e0ff484dcc0003b7"}, {"rev", "3-d93f7f5b2bed878fa8893664c9eb5985"}]}}
    # {:ok, {[id, rev]}}
    # {:ok, {response}} = Couchex.put_attachment(db, doc_id, attachment)
    # IO.inspect response |> Enum.into(%{})

    # {:ok, {[{"id", "18c359e463c37525e0ff484dcc0003b7"}, {"rev", "13-0fa8a291e858dda914acd787111f00ca"}]}}

    # doc_id = "18c359e463c37525e0ff484dcc0003b7"
    # attachment_name = "file.txt"
    # IO.inspect Couchex.delete_attachment(db, doc_id, attachment_name)
    # IO.inspect Couchex.delete_doc(db, doc_id, revision)

  end


  defp server do
    couchdb_url = "http://localhost:5984"
    Couchex.server_connection(couchdb_url, [{:basic_auth, {"thomas", "secret"}}])
  end

end
