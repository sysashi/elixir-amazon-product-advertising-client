defmodule AmazonProductAdvertisingClient.Config do
  @moduledoc """
  The configuration used for authorizing and versioning API requests.
  """

  defstruct "AssociateTag": nil,
    "AWSAccessKeyId": nil,
    "Service": "AWSECommerceService",
    "Version": "2013-08-01",
    aws_secret_access_key: nil

  def build(%{tag: tag, key_id: key_id, key_secret: key_secret}) do
    %__MODULE__{
      "AssociateTag": tag,
      "AWSAccessKeyId": key_id, 
      aws_secret_access_key: key_secret}
  end
end
