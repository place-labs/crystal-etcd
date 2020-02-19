require "./etcd/api"
require "./etcd/client"

module Etcd
  extend self

  VERSION = `shards version`

  class_property logger : Logger = Logger.new(io: STDOUT)

  def from_env(api_version : String? = nil, logger : Logger = Etcd.logger)
    client(
      host: ENV["ETCD_HOST"]? || "localhost",
      port: ENV["ETCD_PORT"]?.try(&.to_i) || 2379,
      api_version: api_version,
      logger: logger
    )
  end

  def client(url : URI, api_version : String? = nil, logger : Logger = Etcd.logger)
    Etcd::Client.new(url: url, api_version: api_version, logger: logger)
  end

  def client(host : String, port : Int32? = nil, api_version : String? = nil, logger : Logger = Etcd.logger)
    Etcd::Client.new(host: host, port: port, api_version: api_version, logger: logger)
  end

  def api(url : URI, api_version : String? = nil, logger : Logger = Etcd.logger)
    Etcd::Api.new(url: url, api_version: api_version, logger: logger)
  end

  def api(host : String, port : Int32? = nil, api_version : String? = nil, logger : Logger = Etcd.logger)
    Etcd::Api.new(host: host, port: port, api_version: api_version, logger: logger)
  end
end
