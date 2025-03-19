require "./base"

module Etcd::Model
  struct Token < WithHeader
    getter token : String
  end

  struct Permissions < WithHeader
    getter perm = [] of Permission
  end

  enum PermissionType
    READ
    WRITE
    READWRITE
  end

  struct Permission < Base
    getter key : String # Bytes
    @[JSON::Field(key: "permType")]
    getter perm_type : PermissionType = PermissionType::READ
    getter range_end : String? = nil # Bytes
  end

  struct Roles < WithHeader
    getter roles = [] of String
  end

  struct Users < WithHeader
    getter users = [] of String
  end
end
