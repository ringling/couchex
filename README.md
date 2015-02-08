# Couchex


Wrapper of [couchbeam](https://github.com/benoitc/couchbeam/) erlang couchdb client


## Create connection
```elixir
couchdb_url = "http://localhost:5984"
server = Couchex.server_connection(couchdb_url, [])
```

Basic authentication
```elixir
couchdb_url = "http://<COUCH_SERVER_URL>:5984"
user="username"
pass="secret"
server = Couchex.server_connection(couchdb_url, [{:basic_auth, {user, pass}}])
```


## Open db
```elixir
{:ok, db} = Couchex.open_db(server, DATABASE_NAME)
```

## Server info
```elixir
{:ok, version} = Couchex.server_info(server)
```

## Open doc
```elixir
{:ok, doc} = Couchex.open_doc(db, id)
{:ok, doc} = Couchex.open_doc(db, id, revision) # by revision
```

## Retreive all docs
```elixir
{:ok, res} = Couchex.all(db)
```

## Save doc
```elixir
doc = %{"key" => "value"}
{:ok, response} = Couchex.save_doc(db, doc)
```

## Save(update) doc

To update a doc, the doc must include the fields `_id` (id of document to update) and `_rev` (current revision of that document)
Function will return `{:error, :conflict}` if the revision, isn't the current in CouchDB

```elixir
doc_id = "18c359e463c37525e0ff484dcc0003b7"
revision = "1-59414e77c768bc202142ac82c2f129de"
doc = %{"key" => "value", "_id" => doc_id, "_rev" => revision}
{:ok, response} = Couchex.save_doc(db, doc)
```

## Delete doc
```elixir
doc_id = "18c359e463c37525e0ff484dcc0003b7"
revision = "1-59414e77c768bc202142ac82c2f129de"
{:ok, response} = Couchex.delete_doc(db, doc_id, revision)
#=> {:ok, %{"id" => "18c359e463c37525e0ff484dcc0003b7", "rev" => "2-fbe18f0e4f4c3c717a9e9291bc2465b7"}}
```


## Put attachment
```elixir
doc_id = "18c359e463c37525e0ff484dcc0003b7"
revision = "1-59414e77c768bc202142ac82c2f129de"
content_type = Couchex.MIME.type("txt") # => "text/plain"
attachment = %{ name: "file.txt", data: "SOME DATA - HERE IT'S TEXT", content_type: content_type }
Couchex.put_attachment(db, doc_id, attachment)
#=> {:ok, %{"id" => "18c359e463c37525e0ff484dcc0003b7", "rev" => "3-ebe18f0e4f4c3c717a9e9291bc2465b3"}}
```

## Fetch attachment
```elixir
doc_id = "18c359e463c37525e0ff484dcc0003b7"
attachment_name = "file.txt"
{:ok, data} = Couchex.fetch_attachment(db, doc_id, attachment_name) #=> {:ok, "SOME DATA - HERE IT'S TEXT"}
```

## Delete attachment

This method is idempotent, and will increment the document revision, even though the attachment isn't present(e.g. already deleted)

```elixir
Couchex.delete_attachment(db, doc_id, attachment_name)
#=> %{"id" => "18c359e463c37525e0ff484dcc0003b7", "rev" => "8-fbe18f0e4f4c3c717a9e9291bc2465b7"}
```

## Fetch view
```elixir
{:ok, res} = Couchex.fetch_view(db, {"stats","grp_by_location"},[:group])
```

## Follow changes on db
```elixir
{:ok, stream_ref} = Couchex.follow(db, [:continuous, :heartbeat])
changes_fun(stream_ref)
```

Function receiving changes
```elixir
def changes_fun(stream_ref) do
  receive do
      {stream_ref, {:done, last_seq}} ->
        IO.puts "stopped, last seq is #{inspect last_seq}"
        :ok
      {stream_ref, {:change, change}} ->
        IO.puts "change row #{inspect change}"
        changes_fun(stream_ref)
      {stream_ref, error}->
        IO.puts "error ? #{inspect error}"
      msg ->
        IO.inspect msg
  end
end
```

