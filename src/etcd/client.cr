require "./kv"
require "./auth"
require "./lease"
require "./maintenance"
require "./watch"

class Etcd::Client
  getter api : Etcd::Api
  getter auth : Etcd::Auth
  getter username : String? = nil
  getter password : String? = nil
  private getter create_api : Proc(Etcd::Api)

  delegate close, to: api.connection

  def initialize(
    url : URI,
    api_version : String? = nil,
    @username : String? = nil,
    @password : String? = nil,
  )
    @create_api = ->{ Etcd::Api.new(uri: url) }
    @api = @create_api.call
    @auth = Etcd::Auth.new(@api)

    update_auth_token
  end

  def initialize(
    host : String = "localhost",
    port : Int32? = nil,
    api_version : String? = nil,
    @username : String? = nil,
    @password : String? = nil,
  )
    @create_api = ->{ Etcd::Api.new(host: host, port: port) }
    @api = @create_api.call
    @auth = Etcd::Auth.new(@api)

    update_auth_token
  end

  def api_version
    api.api_version
  end

  def spawn_api : Etcd::Api
    create_api.call
  end

  # special setter since we need to update the token
  def set_username_password(username : String? = nil, password : String? = nil)
    @username = username
    @password = password
    update_auth_token
  end

  def update_auth_token
    if (username = @username) && (password = @password)
      @api.token = @auth.authenticate(username, password)
    else
      @api.token = nil
    end
  end

  {% for component in %w(kv lease maintenance watch) %}
    # Provide an object for managing {{component.id}}. See `Docker::{{component.id.capitalize}}`.
    def {{component.id}} : {{component.id.capitalize}}
      @{{component.id}} ||= {{component.id.capitalize}}.new(self)
    end
  {% end %}
end
