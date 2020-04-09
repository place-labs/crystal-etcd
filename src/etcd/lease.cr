class Etcd::Lease
  private getter client : Etcd::Client

  def initialize(@client = Etcd::Client.new)
  end

  # Requests a lease
  # ttl   ttl of granted lease                            Int64
  # id    id of 0 prompts etcd to assign any id to lease  UInt64
  def grant(ttl : Int64 = @ttl, id = 0)
    response = client.api.post("/lease/grant", {TTL: ttl, ID: 0})

    body = JSON.parse(response.body)
    {
      id:  body["ID"].to_s.to_i64,
      ttl: body["TTL"].to_s.to_i64,
    }
  end

  # Requests persistence of lease.
  # Must be invoked periodically to avoid key loss.
  def keep_alive(id : Int64)
    response = client.api.post("/lease/keepalive", {ID: id})
    body = JSON.parse(response.body)

    body["result"]["TTL"]?.try &.to_s.to_i64
  end

  # Queries the TTL of a lease
  # id            id of lease                         Int64
  # query_keys    query all the lease's keys for ttl  Bool
  def timetolive(id : Int64, query_keys = false)
    response = client.api.post("/kv/lease/timetolive", {ID: id, keys: query_keys})
    body = JSON.parse(response.body)

    {
      granted_ttl: body["grantedTTL"].to_s.to_i64,
      ttl:         body["TTL"].to_s.to_i64,
    }
  end

  # Revokes an etcd lease
  # id  Id of lease  Int64
  def revoke(id : Int64)
    response = client.api.post("/kv/lease/revoke", {ID: id})

    response.success?
  end

  # Queries for all existing leases in an etcd cluster
  def leases
    response_body = client.api.post("/kv/lease/leases").body
    body = JSON.parse(response_body)

    body["leases"].as_a.map { |l| l["ID"].as_s.to_i64 }
  end
end
