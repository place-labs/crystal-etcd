require "./kv"
require "./auth"
require "./lease"
require "./maintenance"
require "./watch"

class Etcd::Client
  getter! api : Etcd::Api
  getter! auth : Etcd::Auth
  getter username : String?
  getter password : String?
  getter tls_context : HTTP::Client::TLSContext
  private getter create_api : Proc(Etcd::Api)

  delegate close, to: api.connection
  delegate set_username_password, to: api

  def initialize(
    url : URI,
    api_version : String? = nil,
    @username : String? = nil,
    @password : String? = nil,
    @tls_context : HTTP::Client::TLSContext = nil,
  )
    @create_api = -> { Etcd::Api.new(
      api_version: api_version,
      url: url,
      tls_context: tls_context)
    }
    after_initialize
  end

  def initialize(
    endpoints : Array(URI),
    api_version : String? = nil,
    @username : String? = nil,
    @password : String? = nil,
    @tls_context : HTTP::Client::TLSContext = nil,
  )
    @create_api = -> { Etcd::Api.new(
      api_version: api_version,
      endpoints: endpoints,
      username: @username,
      password: @password,
      tls_context: tls_context)
    }
    after_initialize
  end

  def initialize(
    host : String = "localhost",
    port : Int32? = nil,
    api_version : String? = nil,
    @username : String? = nil,
    @password : String? = nil,
    @tls_context : HTTP::Client::TLSContext = nil,
  )
    @create_api = -> { Etcd::Api.new(
      api_version: api_version,
      host: host,
      port: port,
      username: @username,
      password: @password, tls_context: tls_context)
    }
    after_initialize
  end

  def api_version
    api.api_version
  end

  def spawn_api : Etcd::Api
    create_api.call
  end

  {% for component in %w(kv lease maintenance watch) %}
    # Provide an object for managing {{component.id}}. See `Docker::{{component.id.capitalize}}`.
    def {{component.id}} : {{component.id.capitalize}}
      @{{component.id}} ||= {{component.id.capitalize}}.new(self)
    end
  {% end %}

  private def after_initialize
    @api = @create_api.call
    @auth = Etcd::Auth.new(api)
  end
end
