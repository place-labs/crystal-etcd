require "./kv"
require "./lease"
require "./maintenance"
require "./watch"

class Etcd::Client
  getter api : Etcd::Api

  def api_version
    api.api_version
  end

  def initialize(url : URI, api_version : String? = nil)
    @api = Etcd::Api.new(url)
  end

  def initialize(host : String = "localhost", port : Int32? = nil, api_version : String? = nil)
    @api = Etcd::Api.new(host, port)
  end

  {% for component in %w(kv lease maintenance watch) %}
    # Provide an object for managing {{component.id}}. See `Docker::{{component.id.capitalize}}`.
    def {{component.id}} : {{component.id.capitalize}}
      @{{component.id}} ||= {{component.id.capitalize}}.new(api)
    end
  {% end %}
end
