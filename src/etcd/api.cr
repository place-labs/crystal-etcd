require "http"
require "logger"

require "./error"

class Etcd::Api
  # :no_doc:
  # Underlying HTTP connection - exposed for access from test framework only.
  getter connection : HTTP::Client
  getter logger : Logger

  # API version
  property api_version : String

  getter host : String = DEFAULT_HOST
  getter port : Int32 = DEFAULT_PORT
  getter url : URI?
  getter token : String?

  DEFAULT_HOST    = "localhost"
  DEFAULT_PORT    = 2379
  DEFAULT_VERSION = "v3beta"

  def initialize(
    url : URI,
    api_version : String? = nil,
    @logger : Logger = Etcd.logger
  )
    @api_version = api_version || DEFAULT_VERSION
    @connection = HTTP::Client.new(url)
  end

  def initialize(
    host : String = "localhost",
    port : Int32? = nil,
    api_version : String? = nil,
    @logger : Logger = Etcd.logger
  )
    @api_version = api_version || DEFAULT_VERSION
    port ||= DEFAULT_PORT
    @connection = HTTP::Client.new(host, port)
  end

  # TODO: Add connection pooling.
  # Currently, there's contention on the http connection
  # Better to lease connections from a pool, and use the sclient object
  # This way, we can reuse the same infra around the connection
  def spawn_connection
    if url
      HTTP::Client.new(url.as(URI))
    else
      HTTP::Client.new(host, port)
    end
  end

  # Converts literals to string type
  protected def to_stringly(value)
    case value
    when Array, Tuple
      value.map { |v| to_stringly(v) }
    when Hash
      value.transform_values { |v| to_stringly(v) }
    when NamedTuple
      to_stringly(value.to_h)
    when String
      value.as(String)
    when Bool
      value
    else
      value.to_s
    end
  end

  {% for method in %w(get post put delete) %}
    # Executes a {{method.id.upcase}} request on the etcd client connection.
    #
    # The response status will be automatically checked and a Etcd::ApiError raised if
    # unsuccessful.
    # ```
    def {{method.id}}(path, headers : HTTP::Headers? = nil, body : HTTP::Client::BodyType? = nil)
      path = "/#{api_version}#{path}"

      {% if method == "post" %}
        # Client expects non-empty JSON POST body
        body = "{}" if body.nil?
      {% end %}

      response = connection.{{method.id}}(path, headers, body)
      raise Etcd::ApiError.from_response(response) unless response.success?

      response
    end

    # Executes a {{method.id.upcase}} request and yields a `HTTP::Client::Response`.
    #
    # When working with endpoint that provide stream responses these may be accessed as available
    # by calling `#body_io` on the yielded response object.
    #
    # The response status will be automatically checked and a etcd::ApiError raised if
    # unsuccessful.
    def {{method.id}}(path, headers : HTTP::Headers? = nil, body : HTTP::Client::BodyType = nil)
      path = "/#{api_version}#{path}"
      connection.{{method.id}}(path, headers, body) do |response|
        raise Etcd::ApiError.from_response(response) unless response.success?
        yield response
      end
    end

    # Executes a {{method.id.upcase}} request on the etcd client connection with a JSON body
    # formed from the passed `NamedTuple`... or a `Hash`.
    def {{method.id}}(path, body = nil)
      headers = HTTP::Headers{
        "Content-Type" => "application/json",
      }
      body = to_stringly(body) unless body.nil?
      {{method.id}}(path, headers, body.to_json)
    end

    # :ditto:
    def {{method.id}}(path, headers : HTTP::Headers, body = nil)
      headers["Content-Type"] = "application/json"
      body = to_stringly(body) unless body.nil?
      {{method.id}}(path, headers, body.to_json)
    end

    # Executes a {{method.id.upcase}} request on the etcd client connection with a JSON body
    # formed from the passed `NamedTuple` and yields streamed response entries to the block.
    def {{method.id}}(path, body : NamedTuple | Hash)
      headers = HTTP::Headers{
        "Content-Type" => "application/json",
      }
      body = to_stringly(body) unless body.nil?
      {{method.id}}(path, headers, body.to_json) do |response|
        yield response
      end
    end

    # :ditto:
    def {{method.id}}(path, headers : HTTP::Headers, body : NamedTuple | Hash)
      headers["Content-Type"] = "application/json"
      body = to_stringly(body) unless body.nil?
      {{method.id}}(path, headers, body.to_json) do |response|
        yield response
      end
    end
  {% end %}
end
