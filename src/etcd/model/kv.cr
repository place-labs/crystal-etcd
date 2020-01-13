require "./base"

module Etcd::Model
  class Kv < Base
    @[JSON::Field(converter: Etcd::Model::Base64Converter)]
    getter key : String
    @[JSON::Field(converter: Etcd::Model::Base64Converter)]
    getter value : String?
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(UInt64))]
    getter create_revision : UInt64?
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(UInt64))]
    getter mod_revision : UInt64?
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(Int64))]
    getter version : Int64?
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(Int64))]
    getter lease : Int64?
  end

  class RangeResponse < Base
    getter header : Header?
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(Int32))]
    getter count : Int32?
    getter kvs : Array(Kv)?
  end

  class PutResponse < Base
    getter header : Header
    getter prev_kv : Kv?
  end

  class DeleteResponse < Base
    getter header : Header
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(Int32))]
    getter deleted : Int32?
    getter prev_kvs : Array(Kv)?
  end

  class TxnResponse < Base
    getter header : Header
    getter succeeded : Bool = false
    getter responses : Array(JSON::Any) = [] of JSON::Any
  end
end
