require "./base"

module Etcd::Model
  struct Grant < Base
    @[JSON::Field(key: "ID", converter: Etcd::Model::StringTypeConverter(Int64))]
    getter id : Int64
    @[JSON::Field(key: "TTL", converter: Etcd::Model::StringTypeConverter(Int64))]
    getter ttl : Int64
  end

  struct KeepAlive < Base
    @[JSON::Field(root: "TTL", converter: Etcd::Model::StringTypeConverter(Int64))]
    getter result : Int64?
  end

  struct TimeToLive < Base
    @[JSON::Field(key: "grantedTTL", converter: Etcd::Model::StringTypeConverter(Int64))]
    getter granted_ttl : Int64
    @[JSON::Field(key: "TTL", converter: Etcd::Model::StringTypeConverter(Int64))]
    getter ttl : Int64
  end

  struct LeasesArray < Base
    getter leases : Array(LeasesItem)
  end

  struct LeasesItem < Base
    @[JSON::Field(key: "ID", converter: Etcd::Model::StringTypeConverter(Int64))]
    getter id : Int64
  end
end
