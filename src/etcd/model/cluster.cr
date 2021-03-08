require "./base"

module Etcd::Model
  struct MemberAdd < WithHeader
    getter member : Member
    getter members : Array(Member)
  end

  struct Members < WithHeader
    getter members : Array(Member)
  end

  struct Member
    @[JSON::Field(key: "ID", converter: Etcd::Model::StringTypeConverter(UInt64))]
    getter id : UInt64
    @[JSON::Field(key: "clientURLs")]
    getter client_urls : Array(String)
    @[JSON::Field(key: "isLearner")]
    getter is_learner : Bool
    getter name : String
    @[JSON::Field(key: "peerURLs")]
    getter peer_urls : Array(String)
  end
end
