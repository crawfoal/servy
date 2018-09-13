defmodule Servy.Wildthings do
  alias Servy.Bear

  @db_path Path.expand("db", File.cwd!)

  def list_bears do
    @db_path
    |> Path.join("bears.json")
    |> File.read!
    |> Poison.decode!(as: %{ "bears" => [ %Bear{} ] })
    |> Map.get("bears")
  end

  def get_bear(id) when is_integer(id) do
    Enum.find(list_bears(), fn b -> b.id == id end)
  end

  def get_bear(id) when is_binary(id) do
    id |> String.to_integer |> get_bear
  end

  def delete_bear(id) do
    Enum.reject(list_bears(), &(&1.id == id))
  end

  def create_bear(attributes) when is_map attributes do
    struct(Bear, attributes)
  end
end
