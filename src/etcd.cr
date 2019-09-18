require "./etcd/api"
require "./etcd/client"

module Etcd
  extend self

  VERSION = `shards version`

  def from_env
    client(ENV["ETCD_HOST"]? || "localhost", ENV["ETCD_PORT"]?.try &.to_i)
  end

  def client(url : URI)
    Etcd::Client.new(url)
  end

  def client(host : String, port : Int32? = nil)
    Etcd::Client.new(host, port)
  end

  def api(url : URI)
    Etcd::Api.new(url)
  end

  def api(host : String, port : Int32? = nil)
    Etcd::Api.new(host, port)
  end
end
