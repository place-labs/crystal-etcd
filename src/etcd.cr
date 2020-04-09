require "log"
require "./etcd/api"
require "./etcd/client"

module Etcd
  extend self

  # ameba:disable Style/ConstantNames
  Log = ::Log.for("etcd")

  VERSION = `shards version`

  def from_env(api_version : String? = nil)
    client(
      host: ENV["ETCD_HOST"]? || "localhost",
      port: ENV["ETCD_PORT"]?.try(&.to_i) || 2379,
      api_version: api_version,
    )
  end

  def client(url : URI, api_version : String? = nil)
    Etcd::Client.new(url: url, api_version: api_version)
  end

  def client(host : String, port : Int32? = nil, api_version : String? = nil)
    Etcd::Client.new(host: host, port: port, api_version: api_version)
  end

  def api(url : URI, api_version : String? = nil)
    Etcd::Api.new(url: url, api_version: api_version)
  end

  def api(host : String, port : Int32? = nil, api_version : String? = nil)
    Etcd::Api.new(host: host, port: port, api_version: api_version)
  end
end
