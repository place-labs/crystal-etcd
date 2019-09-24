require "./helper"

module Etcd
  describe Kv do
    it "sets a value" do
      client = Etcd.from_env
      response = client.kv.put("#{TEST_PREFIX}/hello", "world")

      response.should be_a Model::PutResponse
    end

    it "queries a range of keys" do
      client = Etcd.from_env

      key, value = "#{TEST_PREFIX}/foo", "bar"
      client.kv.put(key, value)
      response = client.kv.range(key)

      response.should be_a Model::RangeResponse
      values = response.kvs || [] of Model::Kv
      value_present = values.any? { |r| r.key == key && r.value == value }
      value_present.should be_true
    end

    it "queries keys by prefix" do
      client = Etcd.from_env

      ttl = 5_i64
      lease = client.lease.grant ttl
      key0, value0 = "#{TEST_PREFIX}/foo", "bar"
      key1, value1 = "#{TEST_PREFIX}/foot", "bath"

      client.kv.put(key0, value0, lease: lease[:id])
      client.kv.put(key1, value1, lease: lease[:id])
      response = client.kv.range_prefix(key0)

      response.should be_a Model::RangeResponse
      values = response.kvs || [] of Model::Kv
      key_present = values.any? { |r| r.key == key1 && r.value == value1 }
      key_present.should be_true
    end

    it "gets a key" do
      client = Etcd.from_env

      key, value = "#{TEST_PREFIX}/hello", "world"
      client.kv.put(key, value)
      response = client.kv.get(key)
      response.should be_a String
      response.should eq value
    end
  end
end
