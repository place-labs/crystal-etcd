require "./utils"

class Etcd::Kv
  include Utils

  private getter client : Etcd::Client

  def initialize(@client = Etcd::Client.new)
  end

  # Sets a key and value in etcd.
  # key             key is the string that will be base64 encoded and associated with value in the kv store                          String
  # value           value is the string that will be base64 encoded and associated with key in the kv store                          String
  # opts
  #   lease         lease is the lease ID to associate with the key in the key-value store. A lease value of 0 indicates no lease.   Int64
  #   prev_kv       If prev_kv is set, etcd gets the previous key-value pair before changing it.
  #                 The previous key-value pair will be returned in the put response.                                                 Bool
  #   ignore_value  If ignore_value is set, etcd updates the key using its current value. Returns an error if the key does not exist  Bool
  #   ignore_lease  If ignore_lease is set, etcd updates the key using its current lease. Returns an error if the key does not exist  Bool
  def put(
    key : String,
    value,
    lease : Int64 = 0_i64,
    prev_kv : Bool? = nil,
    ignore_value : Bool? = nil,
    ignore_lease : Bool? = nil
  )
    options = {
      :key          => Base64.strict_encode(key),
      :value        => Base64.strict_encode(value.to_s),
      :lease        => lease,
      :prev_kv      => prev_kv,
      :ignore_value => ignore_value,
      :ignore_lease => ignore_lease,
    }.compact
    response = client.api.post("/kv/put", options)

    Model::PutResponse.from_json(response.body)
  end

  # Deletes key or range of keys
  def delete(key, range_end : String? = nil, base64_keys : Bool = true)
    # Otherwise bypass encoding keys
    if base64_keys
      key = Base64.strict_encode(key)
      range_end = range_end.try &->Base64.strict_encode(String)
    end

    post_body = {
      :key       => key,
      :range_end => range_end,
    }.compact
    response = client.api.post("/kv/deleterange", post_body)

    Model::DeleteResponse.from_json(response.body)
  end

  # Deletes an entire keyspace prefix
  def delete_prefix(prefix)
    encoded_prefix = Base64.strict_encode(prefix)
    range_end = prefix_range_end encoded_prefix
    delete(encoded_prefix, range_end, base64_keys: false)
  end

  # Queries a range of keys
  def range(key, range_end : String? = nil, base64_keys : Bool = true)
    # Otherwise bypass encoding keys
    if base64_keys
      key = Base64.strict_encode(key)
      range_end = range_end.try &->Base64.strict_encode(String)
    end

    post_body = {
      :key       => key,
      :range_end => range_end,
    }.compact
    response = client.api.post("/kv/range", post_body)

    Model::RangeResponse.from_json(response.body)
  end

  # Query keys beneath a prefix
  def range_prefix(prefix)
    encoded_prefix = Base64.strict_encode(prefix)
    range_end = prefix_range_end encoded_prefix
    range(encoded_prefix, range_end, base64_keys: false)
  end

  # Query all keys >= key
  def range_greater_than_or_equal(key)
    encoded_key = Base64.strict_encode(key)
    range_end = "\0"
    range(encoded_key, range_end, base64_keys: false)
  end

  # Non-Standard Requests
  ##############################################################################

  def get(key) : String?
    result = range(key)
    result.try(&.kvs).try(&.first?).try(&.value)
  end
end
