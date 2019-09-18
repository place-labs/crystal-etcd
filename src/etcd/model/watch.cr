require "./base"
require "./kv"

module Etcd::Model
  class WatchResponse < Base
    getter result : WatchResult
    getter error : WatchError?
    getter created : Bool = false
  end

  class WatchError < Base
    @[JSON::Field(converter: Etcd::Model::StringTypeConverter(Int32))]
    getter http_code : Int32
  end

  class WatchResult < Base
    getter events : Array(Etcd::Model::WatchEvent) = [] of Etcd::Model::WatchEvent
  end

  class WatchEvent < Base
    enum Type
      PUT
      DELETE
    end

    # Empty type field indicates PUT event
    getter type : Etcd::Model::WatchEvent::Type = Etcd::Model::WatchEvent::Type::PUT
    getter kv : Kv
  end
end
