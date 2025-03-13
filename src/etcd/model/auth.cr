require "./base"

module Etcd::Model
  struct Token < WithHeader
    getter token : String
  end

  struct Permissions < WithHeader
    getter perm : Array(Permission)
  end

  enum PermissionType
    READ
    WRITE
    READWRITE
  end

  struct Permission < WithHeader
    getter key : String # Bytes
    @[JSON::Field(key: "permType")]
    getter perm_type : PermissionType
    getter range_end : String # Bytes
  end

  struct Roles < WithHeader
    getter roles : Array(String)
  end

  struct Users < WithHeader
    getter users : Array(String)
  end
end
