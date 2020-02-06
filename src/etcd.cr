require "./etcd/api"
require "./etcd/client"

module Etcd
  extend self

  VERSION = `shards version`

  def from_env(api_version : String? = nil)
    client(
      host: ENV["ETCD_HOST"]? || "localhost",
      port: ENV["ETCD_PORT"]?.try(&.to_i) || 2379,
      api_version: api_version,
    )
  end

  def client(url : URI, api_version : String? = nil)
    Etcd::Client.new(url, api_version)
  end

  def client(host : String, port : Int32? = nil, api_version : String? = nil)
    Etcd::Client.new(host, port, api_version)
  end

  def api(url : URI, api_version : String? = nil)
    Etcd::Api.new(url, api_version)
  end

  def api(host : String, port : Int32? = nil, api_version : String? = nil)
    Etcd::Api.new(host, port, api_version)
  end
end
