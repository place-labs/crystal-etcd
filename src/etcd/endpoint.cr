require "./client"

abstract class Endpoint
  private getter client : Etcd::Client

  def initialize(@client = Etcd::Client.new)
  end

  private macro request(verb, path, arguments, response_type)
    begin
      %response = client.api.{{ verb.downcase.id }}({{ path }}, body: {{ arguments }})
      %body = %response.body
      %result = {{ response_type }}.from_json(%body)
    rescue e : JSON::SerializableError
      raise Error.new("incorrect {{ verb.id }} {{ path.id }} response: #{ %body }", cause: e)
    end

    unless (%error = %result.error).nil? && %response.success?
      raise Error.new(%error.try(&.message) || "Unsuccessful response")
    end

    %result
  end
end
