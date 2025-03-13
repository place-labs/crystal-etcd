require "./model/auth"
require "./utils"

class Etcd::Auth
  include Utils

  private getter api : Etcd::Api

  def initialize(@api = Etcd::Api.new)
  end

  # auth/authenticate
  def authenticate(name : String, password : String)
    validate!(name)

    response = api.post("/auth/authenticate", {name: name, password: password}).body
    Model::Token.from_json(response).token
  end

  # auth/disable
  def disable
    api.post("/auth/disable").success?
  end

  # auth/enable
  def enable
    api.post("/auth/enable").success?
  end

  # auth/role/add
  def role_add(name : String)
    validate!(name)

    api.post("/auth/role/add", {name: name}).success?
  end

  # auth/role/delete
  def role_delete(role : String)
    api.post("/auth/role/delete", {role: role}).success?
  end

  # auth/role/get
  def role_get(role : String)
    response = api.post("/auth/role/get", {role: role}).body
    Model::Permissions.from_json(response).perm
  end

  # auth/role/grant
  def role_grant(role : String, perm_key : String, range_end : String? = nil, perm_type = Model::PermissionType::READ, base64_keys : Bool = true)
    validate!(role)

    if base64_keys
      perm_key = Base64.strict_encode(perm_key)
      range_end = range_end.try &->Base64.strict_encode(String)
    end

    options = {
      :name => role,
      :perm => {
        :key       => perm_key,
        :permType  => perm_type.to_s,
        :range_end => range_end,
      },
    }

    api.post("/auth/role/grant", options).success?
  end

  def role_grant_prefix(name : String, prefix : String, perm_type = Model::PermissionType::READ)
    encoded_prefix = Base64.strict_encode(prefix)
    encoded_range_end = prefix_range_end encoded_prefix
    role_grant(name, encoded_prefix, encoded_range_end, perm_type, base64_keys: false)
  end

  # auth/role/list
  def role_list
    response = api.post("/auth/role/list").body
    Model::Roles.from_json(response).roles
  end

  # auth/role/revoke
  def role_revoke(role : String, key : String, range_end : String? = nil, base64_keys : Bool = true)
    validate!(role)

    if base64_keys
      key = Base64.strict_encode(key)
      range_end = range_end.try &->Base64.strict_encode(String)
    end

    # why is this API call totally different from the grant?!
    options = {
      :role => role,
      :key       => key,
      :range_end => range_end,
    }

    api.post("/auth/role/revoke", options).success?
  end

  def role_revoke_prefix(role : String, prefix : String)
    encoded_prefix = Base64.strict_encode(prefix)
    encoded_range_end = prefix_range_end encoded_prefix
    role_revoke(role, encoded_prefix, encoded_range_end, base64_keys: false)
  end

  # auth/user/add
  def user_add(name : String, password : String, no_password : Bool = false)
    validate!(name)

    options = {
      :name    => name,
      :options => {
        :no_password => no_password,
      },
      :password => password,
    }

    api.post("/auth/user/add", options).success?
  end

  # auth/user/changepw
  def user_changepw(name : String, password : String)
    validate!(name)

    api.post("/auth/user/changepw", {name: name, password: password}).success?
  end

  # auth/user/delete
  def user_delete(name : String)
    validate!(name)

    api.post("/auth/user/delete", {name: name}).success?
  end

  # auth/user/get
  def user_get(name : String)
    validate!(name)

    response = api.post("/auth/user/get", {name: name}).body
    Model::Roles.from_json(response).roles
  end

  # auth/user/grant
  def user_grant(role : String, user : String)
    api.post("/auth/user/grant", {user: user, role: role}).success?
  end

  # auth/user/list
  def user_list
    response = api.post("/auth/user/list").body
    Model::Users.from_json(response).users
  end

  # auth/user/revoke
  def user_revoke(name : String, role : String)
    validate!(name)
    api.post("/auth/user/revoke").success?
  end

  private def validate!(name : String)
    raise ArgumentError.new("`name` is empty") if name.empty?
  end
end
