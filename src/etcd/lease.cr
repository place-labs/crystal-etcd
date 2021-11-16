require "./model/lease"
require "./endpoint"

module Etcd
  class Lease < Endpoint
    # /kv/lease/leases
    # /lease/leases
    # Queries for all existing leases in an etcd cluster
    def leases
      request(
        "POST",
        "/kv/lease/leases",
        nil,
        Model::Leases,
      ).leases.map(&.id)
    end

    # /kv/lease/revoke
    # Revokes an etcd lease
    # id  Id of lease  Int64
    def revoke(id : Int64)
      request(
        "POST",
        "/kv/lease/revoke",
        {ID: id},
        Model::EmptyResponse,
      )

      true
    end

    # /kv/lease/timetolive
    # /lease/timetolive
    # Queries the TTL of a lease
    # id            id of lease                         Int64
    # query_keys    query all the lease's keys for ttl  Bool
    def timetolive(id : Int64, query_keys = false)
      request(
        "POST",
        "/kv/lease/timetolive",
        {ID: id, keys: query_keys},
        Model::TimeToLive,
      )
    end

    # /lease/grant
    # Requests a lease
    # ttl   ttl of granted lease                            Int64
    # id    id of 0 prompts etcd to assign any id to lease  UInt64
    def grant(ttl : Int64 = @ttl, id = 0)
      request(
        "POST",
        "/lease/grant",
        {TTL: ttl, ID: 0},
        Model::Grant
      )
    end

    # /lease/keepalive
    # Requests persistence of lease.
    # Must be invoked periodically to avoid key loss.
    def keep_alive(id : Int64) : Int64?
      request(
        "POST",
        "/lease/keepalive",
        {ID: id},
        Model::KeepAlive
      ).result
    end
  end
end
