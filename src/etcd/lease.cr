require "./model/lease"

class Etcd::Lease
  private getter client : Etcd::Client

  def initialize(@client = Etcd::Client.new)
  end

  # Requests a lease
  # ttl   ttl of granted lease                            Int64
  # id    id of 0 prompts etcd to assign any id to lease  UInt64
  def grant(ttl : Int64 = @ttl, id = 0)
    Model::Grant.from_json(client.api.post("/lease/grant", {TTL: ttl, ID: 0}).body)
  end

  # Requests persistence of lease.
  # Must be invoked periodically to avoid key loss.
  def keep_alive(id : Int64)
    Model::KeepAlive.from_json(client.api.post("/lease/keepalive", {ID: id}).body).result
  end

  # Queries the TTL of a lease
  # id            id of lease                         Int64
  # query_keys    query all the lease's keys for ttl  Bool
  def timetolive(id : Int64, query_keys = false)
    Model::TimeToLive.from_json(client.api.post("/kv/lease/timetolive", {ID: id, keys: query_keys}).body)
  end

  # Revokes an etcd lease
  # id  Id of lease  Int64
  def revoke(id : Int64)
    client.api.post("/kv/lease/revoke", {ID: id}).success?
  end

  # Queries for all existing leases in an etcd cluster
  def leases
    Model::LeasesArray.from_json(client.api.post("/kv/lease/leases").body).leases.map(&.id)
  end
end
