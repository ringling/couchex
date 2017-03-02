defmodule Couchex.MIME do
  @moduledoc """
  Maps MIME types to file extensions and vice versa.
  """

  @compile :no_native
  @default_type "application/octet-stream"

  # Read all the MIME types mappings into the `mapping` variable.
  @external_resource "lib/mime.types"
  stream = File.stream!("lib/mime.types")

  mapping = Enum.flat_map(stream, fn (line) ->
    if String.starts_with?(line, ["#", "\n"]) do
      []
    else
      [type|exts] = line |> String.strip |> String.split
      [{type, exts}]
    end
  end)

  @doc """
  Returns whether a MIME type is registered.

  ## Examples

      iex> Couchex.MIME.valid?("text/plain")
      true

      iex> Couchex.MIME.valid?("foo/bar")
      false

  """

  @spec valid?(String.t) :: boolean
  def valid?(type) do
    is_list entry(type)
  end

  @doc """
  Returns the extensions associated with a given MIME type.

  ## Examples

      iex> Couchex.MIME.extensions("text/html")
      ["html", "htm"]

      iex> Couchex.MIME.extensions("application/json")
      ["json"]

      iex> Couchex.MIME.extensions("foo/bar")
      []

  """

  @spec extensions(String.t) :: [String.t]
  def extensions(type) do
    entry(type) || []
  end

  @doc """
  Returns the MIME type associated with a file extension. If no MIME type is
  known for `file_extension`, `#{inspect @default_type}` is returned.

  ## Examples

      iex> Couchex.MIME.type("txt")
      "text/plain"

      iex> Couchex.MIME.type("foobarbaz")
      #{inspect @default_type}

  """

  @spec type(String.t) :: String.t
  def type(file_extension)

  for {type, exts} <- mapping, ext <- exts do
    def type(unquote(ext)), do: unquote(type)
  end

  def type(_ext), do: @default_type

  @doc """
  Guesses the MIME type based on the path's extension. See `type/1`.

  ## Examples

      iex> Couchex.MIME.path("index.html")
      "text/html"

  """

  @spec path(Path.t) :: String.t
  def path(path) do
    case Path.extname(path) do
      "." <> ext -> type(ext)
      _ -> @default_type
    end
  end

  # entry/1
  @spec entry(String.t) :: list(String.t)

  for {type, exts} <- mapping do
    defp entry(unquote(type)), do: unquote(exts)
  end

  defp entry(_type), do: nil
end
