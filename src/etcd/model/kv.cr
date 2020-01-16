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
    getter count : Int32 = 0
    getter kvs : Array(Etcd::Model::Kv) = [] of Etcd::Model::Kv
  end

  class PutResponse < Base
    getter header : Header
    getter prev_kv : Kv?
  end

  class DeleteResponse < Base
    getter header : Header
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(Int32))]
    getter deleted : Int32 = 0
    getter prev_kvs : Array(Etcd::Model::Kv) = [] of Etcd::Model::Kv
  end

  class TxnResponse < Base
    getter header : Header
    getter succeeded : Bool = false

    alias Response = NamedTuple(
      response_range: Etcd::Model::RangeResponse?,
      response_put: Etcd::Model::PutResponse?,
      response_delete: Etcd::Model::DeleteResponse?,
    )
    getter responses : Array(Etcd::Model::TxnResponse::Response) = [] of Etcd::Model::TxnResponse::Response
  end
end
