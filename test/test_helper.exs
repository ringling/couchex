ExUnit.start()

defmodule TestHelper do
  def server do
    Couchex.server_connection(server_url, [{:basic_auth, {"thomas", "secret"}}])
  end

  def server_url do
    "http://localhost:5984"
  end

  def put_txt_attachement(db, doc_id, name) do
    content_type = Couchex.MIME.type("txt") # => "text/plain"
    attachment = %{ name: name, data: "SOME DATA - HERE IT'S TEXT", content_type: content_type }
    Couchex.put_attachment(db, %{id: doc_id}, attachment)
  end

  def insert_doc(db, doc) do
    {:ok, resp_doc} = Couchex.save_doc(db, doc)
    resp_doc
  end
end