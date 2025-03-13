require "http"

require "./error"

class Etcd::Api
  # API version
  property api_version : String
  property token : String?

  getter host : String = DEFAULT_HOST
  getter port : Int32 = DEFAULT_PORT
  getter endpoints = [] of URI
  getter tls_context : HTTP::Client::TLSContext?

  # keeps track of the number of times we've tried to connect since the last successful request
  # (will be used to keep trying if we have multiple endpoints)
  getter retries_performed = 0

  # will be rebuilt on failure to point to the next endpoint
  @connection : HTTP::Client? = nil

  DEFAULT_HOST    = "localhost"
  DEFAULT_PORT    = 2379
  DEFAULT_VERSION = "v3"

  def initialize(
    url : URI,
    @api_version : String = DEFAULT_VERSION,
    @secure = false,
    @tls_context : HTTP::Client::TLSContext? = nil,
  )
    initialize([url], api_version, @secure, @tls_context)
  end

  def initialize(
    @endpoints : Array(URI),
    @api_version : String = DEFAULT_VERSION,
    @secure = false,
    @tls_context : HTTP::Client::TLSContext? = nil,
  )
  end

  def initialize(
    host : String = "localhost",
    port : Int32? = nil,
    @api_version : String = DEFAULT_VERSION,
    @secure = false,
    @tls_context : HTTP::Client::TLSContext? = nil,
  )
    url = URI.new(
      scheme: secure ? "https" : "http",
      host: host,
      port: port,
    )
    initialize(url, api_version, @secure, @tls_context)
  end

  # TODO: Add connection pooling.
  # Currently, there's contention on the http connection
  # Better to lease connections from a pool, and use the sclient object
  # This way, we can reuse the same infra around the connection
  # def spawn_connection
  #   if url
  #     HTTP::Client.new(url.as(URI))
  #   else
  #     HTTP::Client.new(host, port)
  #   end
  # end

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

  # :no_doc:
  # used to move to the next available endpoint in case of failure
  # exposed for the unit tests
  def rotate_endpoints
    Log.debug { "Rotating endpoints" }
    @endpoints.rotate!
    @connection = create_connection
  end

  # current url (may change on failure)
  def url
    @endpoints.first
  end

  protected def connection
    @connection ||= create_connection
  end

  protected def create_connection
    client = HTTP::Client.new(
      url,
      tls: @tls_context
    )

    # TODO: make configurable
    client.dns_timeout = 2.seconds
    client.connect_timeout = 1.second

    client
  end

  {% for method in %w(get post put delete) %}
    # Executes a {{method.id.upcase}} request on the etcd client connection.
    #
    # The response status will be automatically checked and a Etcd::ApiError raised if
    # unsuccessful.
    # ```
    def {{method.id}}(path, headers : HTTP::Headers? = nil, body : HTTP::Client::BodyType? = nil)
      prefixed_path = "/#{api_version}#{path}"

      {% if method == "post" %}
        # Client expects non-empty JSON POST body
        body = "{}" if body.nil?
      {% end %}

      if token = @token
        if headers = headers || HTTP::Headers.new
          headers["Authorization"] = token
        end
      end

      begin
        response = connection.{{method.id}}(prefixed_path, headers, body)
      rescue IO::TimeoutError | Socket::ConnectError
        @retries_performed += 1

        if @retries_performed < @endpoints.size
          rotate_endpoints
          return {{method.id}}(path, headers, body)
        else
          raise Etcd::ConnectionError.new(url)
        end
      end

      raise Etcd::ApiError.from_response(response) unless response.success?

      @retries_performed = 0

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
