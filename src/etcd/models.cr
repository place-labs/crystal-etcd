# Models of Etcd Data.
# Refer to documentation https://coreos.com/etcd/docs/latest/dev-guide/api_reference_v3.html
module Etcd::Model
  private class Data
    include JSON::Serializable
  end

  class KV < Data
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

  class Header < Data
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(UInt64))]
    getter cluster_id : UInt64
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(UInt64))]
    getter member_id : UInt64
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(Int64))]
    getter revision : Int64
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(UInt64))]
    getter raft_term : UInt64
  end

  class RangeResponse < Data
    getter header : Header
    getter kvs : Array(KV)
    getter count : String
  end

  class WatchResponse < Data
    getter result : WatchResult
    getter error : WatchError
    getter created : Bool = false
  end

  class WatchError < Data
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(Int32))]
    getter http_code : Int32
  end

  class WatchResult < Data
    getter events : Array(Etcd::Model::WatchEvent) = [] of Etcd::Model::WatchEvent
  end

  class WatchEvent < Data
    enum Type
      PUT
      DELETE
    end

    # Empty type field indicates PUT event
    getter type : Etcd::Model::WatchEvent::Type = Etcd::Model::WatchEvent::Type::PUT
    getter kv : KV
  end

  class Status < Data
    getter header : Header
    getter version : String
    @[JSON::Field(key: "dbSize", converter: Etcd::Model::StringTypeConverter(Int64))]
    getter db_size : Int64
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(UInt64))]
    getter leader : UInt64
    @[JSON::Field(key: "raftIndex", converter: Etcd::Model::StringTypeConverter(UInt64))]
    getter raft_index : UInt64
    @[JSON::Field(key: "raftTerm", converter: Etcd::Model::StringTypeConverter(UInt64))]
    getter raft_term : UInt64
  end

  # Converter for Base64 encoded values
  module Base64Converter
    def self.from_json(json : JSON::PullParser) : String
      string = Base64.decode_string(json.read_string)
      string
    end

    def self.to_json(value : String, json : JSON::Builder)
      json.string(Base64.strict_encode(value))
    end
  end

  # Converter for stringly typed values, such as etcd response values
  module StringTypeConverter(T)
    def self.from_json(json : JSON::PullParser) : T
      T.new(json.read_string)
    end

    def self.to_json(value : T, json : JSON::Builder)
      json.string(value.to_s)
    end
  end
end
