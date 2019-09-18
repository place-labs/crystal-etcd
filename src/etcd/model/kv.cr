require "./base"

module Etcd::Model
  class Kv < Base
    @[JSON::Field(converter: Etcd::Model::Base64Converter)]
    getter key : String
    @[JSON::Field(converter: Etcd::Model::Base64Converter)]
    getter value : String
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(UInt64))]
    getter create_revision : UInt64
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(UInt64))]
    getter mod_revision : UInt64
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(Int64))]
    getter version : Int64
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(Int64))]
    getter lease : Int64
  end

  class RangeResponse < Base
    getter header : Header
    getter kvs : Array(Kv)
    getter count : String
  end
end
