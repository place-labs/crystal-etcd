require "./base"

module Etcd::Model
  class Status < Base
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
end
