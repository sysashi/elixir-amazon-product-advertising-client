defmodule AmazonProductAdvertisingClient.BrowseNodeLookup do
  @opaque t :: %__MODULE__{}

  alias __MODULE__
  alias AmazonProductAdvertisingClient.Config

  defstruct "Operation": "BrowseNodeLookup",
    "ResponseGroup": "BrowseNodeInfo",
    "BrowseNodeId": nil

  def execute(browse_node_params \\ %BrowseNodeLookup{}, config \\ %Config{}) do
    AmazonProductAdvertisingClient.call_api browse_node_params, config
  end
end
