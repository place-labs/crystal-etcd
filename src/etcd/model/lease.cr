require "./base"

module Etcd::Model
  struct Leases < WithHeader
    getter leases : Array(Lease)
  end

  struct Lease < Base
    @[JSON::Field(key: "ID", converter: Etcd::Model::StringTypeConverter(Int64))]
    getter id : Int64
  end

  struct TimeToLive < WithHeader
    @[JSON::Field(key: "ID", converter: Etcd::Model::StringTypeConverter(Int64))]
    getter id : Int64
    @[JSON::Field(key: "TTL", converter: Etcd::Model::StringTypeConverter(Int64))]
    getter ttl : Int64
    @[JSON::Field(key: "grantedTTL", converter: Etcd::Model::StringTypeConverter(Int64))]
    getter granted_ttl : Int64
    getter keys : Array(String)? # This should be Array(Bytes)?
  end

  # Returns error
  struct Grant < WithHeader
    @[JSON::Field(key: "ID", converter: Etcd::Model::StringTypeConverter(Int64))]
    getter id : Int64
    @[JSON::Field(key: "TTL", converter: Etcd::Model::StringTypeConverter(Int64))]
    getter ttl : Int64
  end

  # Returns error
  struct KeepAlive < Response
    getter result : Result?

    struct Result < Base
      @[JSON::Field(key: "TTL", converter: Etcd::Model::StringTypeConverter(Int64))]
      getter ttl : Int64?
    end
  end
end
