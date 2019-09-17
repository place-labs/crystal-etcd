require "json"
require "http"

require "./etcd/client"

module Etcd
  extend self

  VERSION = `shards version`

  def from_env
    client(ENV["ETCD_HOST"], ENV["ETCD_PORT"]?)
  end

  def client(url : URI)
    Etcd::Client.new(url)
  end

  def client(host : String, port : Int32? = nil)
    Etcd::Client.new(host, port)
  end
end
