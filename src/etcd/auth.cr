class Etcd::Auth
  private getter api : Etcd::Api

  def initialize(@api = Etcd::Api.new)
  end

  # auth/authenticate
  def authenticate(name : String, password : String)
    validate!(name)

    response = client.api.post("/auth/auth/authenticate", {name: name, password: password}).body
    Model::Token.from_json(response).token
  end

  # auth/disable
  def disable
    client.api.post("/auth/auth/disable").success?
  end

  # auth/enable
  def enable
    client.api.post("/auth/auth/enable").success?
  end

  # auth/role/add
  def role_add(name : String)
    validate!(name)

    client.api.post("/auth/role/add", {name: name}).success?
  end

  # auth/role/delete
  def role_delete(role : String)
    client.api.post("/auth/role/delete", {role: role}).success?
  end

  # auth/role/get
  def role_get(role : String)
    response = client.api.post("/auth/role/get", {role: role}).body
    Model::Permissions.from_json(response).perm
  end

  # auth/role/grant
  def role_grant(name : String, perm_key : String, range_end : String)
    validate!(name)

    options = {
      :name => name,
      :perm => {
        :key       => perm_key,
        :permType  => "READ",
        :range_end => range_end,
      },
    }

    client.api.post("/auth/role/grant", options).success?
  end

  # auth/role/list
  def role_list
    response = client.api.post("/auth/role/list").body
    Roles.from_json(response).roles
  end

  # auth/role/revoke
  def role_revoke(key : String, range_end : String, role : String)
    client.api.post("/auth/role/revoke").success?
  end

  # auth/user/add
  def user_add(name : String, password : String, no_password : Bool)
    validate!(name)

    options = {
      :name    => name,
      :options => {
        :no_password => no_password,
      },
      :password => password,
    }

    client.api.post("/auth/user/add", options).success?
  end

  # auth/user/changepw
  def user_changepw(name : String, password : String)
    validate!(name)

    client.api.post("/auth/user/changepw", {name: name, password: password}).success?
  end

  # auth/user/delete
  def user_delete(name : String)
    validate!(name)

    client.api.post("/auth/user/delete", {name: name}).success?
  end

  # auth/user/get
  def user_get(name : String)
    validate!(name)

    response = client.api.post("/auth/user/get", {name: name}).body
    Model::Roles.from_json(response).roles
  end

  # auth/user/grant
  def user_grant(role : String, user : String)
    client.api.post("/auth/user/grant").success?
  end

  # auth/user/list
  def user_list
    response = client.api.post("/auth/user/list").body
    Model::Users.from_json(response).users
  end

  # auth/user/revoke
  def user_revoke(name : String, role : String)
    validate!(name)
    client.api.post("/auth/user/revoke").success?
  end

  private def validate!(name : String)
    raise ArgumentError.new("`name` is empty") if name.empty?
  end
end
