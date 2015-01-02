# Couchex


Wrapper of [couchbeam](https://github.com/benoitc/couchbeam/) erlang couchdb client


## Create connection
```elixir
couchdb_url = "http://localhost:5984"
server = Couchex.server_connection(couchdb_url, [{:basic_auth, {USER, PASS}}])
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

