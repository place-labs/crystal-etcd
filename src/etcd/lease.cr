require "./model/lease"

class Etcd::Lease
  private getter client : Etcd::Client

  def initialize(@client = Etcd::Client.new)
  end

  # /kv/lease/leases
  # /lease/leases
  # Queries for all existing leases in an etcd cluster
  def leases
    Model::Leases.from_json(client.api.post("/kv/lease/leases").body).leases.map(&.id)
  end

  # Requests persistence of lease.
  # Must be invoked periodically to avoid key loss.
  def keep_alive(id : Int64) : Int64?
    Model::KeepAlive.from_json(client.api.post("/lease/keepalive", {ID: id}).body).result
  rescue JSON::SerializableError
    nil
  end

  # /kv/lease/revoke
  # Revokes an etcd lease
  # id  Id of lease  Int64
  def revoke(id : Int64)
    # To get header: Etcd::Model::WithHeader.from_json(response.body)
    client.api.post("/kv/lease/revoke", {ID: id}).success?
  end

  # /kv/lease/timetolive
  # /lease/timetolive
  # Queries the TTL of a lease
  # id            id of lease                         Int64
  # query_keys    query all the lease's keys for ttl  Bool
  def timetolive(id : Int64, query_keys = false)
    Model::TimeToLive.from_json(client.api.post("/kv/lease/timetolive", {ID: id, keys: query_keys}).body)
  end

  # /lease/grant
  # Requests a lease
  # ttl   ttl of granted lease                            Int64
  # id    id of 0 prompts etcd to assign any id to lease  UInt64
  def grant(ttl : Int64 = @ttl, id = 0)
    Model::Grant.from_json(client.api.post("/lease/grant", {TTL: ttl, ID: 0}).body)
  end

  # /lease/keepalive
  # Requests persistence of lease.
  # Must be invoked periodically to avoid key loss.
  def keep_alive(id : Int64) : Int64?
    model = Model::KeepAlive.from_json(client.api.post("/lease/keepalive", {ID: id}).body)
    raise Exception.new(model.error.not_nil!.to_s) if model.result.nil?
    model.result.not_nil!.ttl
  end
end
