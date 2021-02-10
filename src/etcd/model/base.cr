require "json"

# Etcd data models
# Refer to documentation https://coreos.com/etcd/docs/latest/dev-guide/api_reference_v3.html
module Etcd::Model
  private abstract struct Base
    include JSON::Serializable
  end

  struct Header < Base
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(UInt64))]
    getter cluster_id : UInt64?
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(UInt64))]
    getter member_id : UInt64?
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(Int64))]
    getter revision : Int64
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(UInt64))]
    getter raft_term : UInt64?
  end

  # Converter for Base64 encoded values
  module Base64Converter
    def self.from_json(json : JSON::PullParser) : String
      Base64.decode_string(json.read_string)
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
