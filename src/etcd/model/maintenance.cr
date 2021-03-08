require "./base"

module Etcd::Model
  enum AlarmAction
    GET
    ACTIVATE
    DEACTIVATE
  end

  enum AlarmType
    NONE
    NOSPACE
    CORRUPT
  end

  struct Alarm < Base
    getter alarm : AlarmType
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(UInt64))]
    getter member_id : UInt64
  end

  struct Alarms < WithHeader
    getter alarms : Array(Alarm)
  end

  struct Revision < WithHeader
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(Int64))]
    getter compact_revision : Int64
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(Int64))]
    getter hash : Int64
  end

  struct Snapshot < Base
    getter error : Error?
    getter result : SnapshotResult?
  end

  struct SnapshotResult < WithHeader
    getter blob : String # Bytes
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(UInt64))]
    getter remaining_bytes : UInt64
  end

  struct Status < WithHeader
    @[JSON::Field(key: "dbSize", converter: Etcd::Model::StringTypeConverter(Int64))]
    getter db_size : Int64
    @[JSON::Field(key: "dbSizeInUse", converter: Etcd::Model::StringTypeConverter(Int64))]
    getter db_size_in_use : Int64
    getter errors : Array(String)?
    @[JSON::Field(key: "isLearner")]
    getter is_learner : Bool?
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(UInt64))]
    getter leader : UInt64
    @[JSON::Field(key: "raftAppliedIndex", converter: Etcd::Model::StringTypeConverter(UInt64))]
    getter raft_applied_index : UInt64
    @[JSON::Field(key: "raftIndex", converter: Etcd::Model::StringTypeConverter(UInt64))]
    getter raft_index : UInt64
    @[JSON::Field(key: "raftTerm", converter: Etcd::Model::StringTypeConverter(UInt64))]
    getter raft_term : UInt64
    getter version : String
  end
end
