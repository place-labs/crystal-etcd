module Etcd::KV
  # Sets a key and value in etcd.
  # key             key is the string that will be base64 encoded and associated with value in the kv store                          String
  # value           value is the string that will be base64 encoded and associated with key in the kv store                          String
  # opts
  #   lease         lease is the lease ID to associate with the key in the key-value store. A lease value of 0 indicates no lease.   Int64
  #   prev_kv       If prev_kv is set, etcd gets the previous key-value pair before changing it.
  #                 The previous key-value pair will be returned in the put response.                                                 Bool
  #   ignore_value  If ignore_value is set, etcd updates the key using its current value. Returns an error if the key does not exist  Bool
  #   ignore_lease  If ignore_lease is set, etcd updates the key using its current lease. Returns an error if the key does not exist  Bool
  def put(key, value, **opts)
    opts = {
      key:   Base64.strict_encode(key),
      value: Base64.strict_encode(value),
      lease: 0_i64,
    }.merge(opts)

    parameters = {} of Symbol => String | Int64 | Bool
    {:key, :value, :lease, :prev_kv, :ignore_value, :ignore_lease}.each do |param|
      parameters[param] = opts[param] if opts.has_key?(param)
    end
    response = post("/kv/put", parameters)

    if opts["prev_kv"]?
      JSON.parse(response.body)["prev_kv"]
    else
      response.success?
    end
  end

  # Deletes key or range of keys
  def delete(key, range_end = "")
    post_body = {
      :key       => Base64.strict_encode(key),
      :range_end => Base64.strict_encode(range_end),
    }
    response = post("/kv/deleterange", post_body)

    raise "Etcd Error: #{response.body}" unless response.success?

    JSON.parse(response.body)["deleted"]?.try(&.to_s.to_i64) || 0
  end

  # Deletes an entire keyspace prefix
  def delete_prefix(prefix)
    delete(prefix, prefix_range_end prefix)
  end

  # Calculate range_end for given prefix
  def prefix_range_end(prefix)
    prefix.size > 0 ? prefix.sub(-1, prefix[-1] + 1) : ""
  end

  # Queries a range of keys
  def range(key, range_end : String? = nil)
    encoded_key = Base64.strict_encode(key)
    encoded_range_end = range_end.try &->Base64.strict_encode(String)

    parameters = {
      :key       => encoded_key,
      :range_end => encoded_range_end,
    }.compact

    response = post("/kv/range", parameters)
    Model::RangeResponse.from_json(response.body).kvs || [] of Model::KV
  end

  # Query keys beneath a prefix
  def range_prefix(prefix)
    range(prefix, prefix_range_end prefix)
  end
end
