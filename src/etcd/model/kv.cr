require "./base"

module Etcd::Model
  struct Kv < Base
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(UInt64))]
    getter create_revision : UInt64?
    @[JSON::Field(converter: Etcd::Model::Base64Converter)]
    getter key : String
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(Int64))]
    getter lease : Int64?
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(UInt64))]
    getter mod_revision : UInt64?
    @[JSON::Field(converter: Etcd::Model::Base64Converter)]
    getter value : String?
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(Int64))]
    getter version : Int64?
  end

  struct Range < Base
    getter header : Header?
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(Int32))]
    getter count : Int32 = 0
    getter kvs : Array(Etcd::Model::Kv) = [] of Etcd::Model::Kv
  end

  struct Put < WithHeader
    getter prev_kv : Kv?
  end

  struct Delete < WithHeader
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(Int32))]
    getter deleted : Int32 = 0
    getter prev_kvs : Array(Etcd::Model::Kv) = [] of Etcd::Model::Kv
  end

  struct TxnResponse < Base
    getter response_range : Range?
    getter response_put : Put?
    getter response_delete : Delete?
  end

  struct Txn < WithHeader
    getter succeeded : Bool = false
    getter responses : Array(TxnResponse) = [] of TxnResponse
  end
end
