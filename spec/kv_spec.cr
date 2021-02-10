require "uuid"
require "./helper"

module Etcd
  describe Kv do
    describe "compare_and_swap" do
      it "puts if compare succeeds" do
        client = Etcd.from_env
        key = "#{TEST_PREFIX}/hello"
        value0 = "world"
        value1 = "friends"
        client.kv.put(key, value0)
        success = client.kv.compare_and_swap(key, value: value1, previous_value: value0)
        success.should be_true
        client.kv.get(key).should eq value1
      end

      it "fails if compare fails" do
        client = Etcd.from_env
        key = "#{TEST_PREFIX}/hello"
        value0 = "world"
        value1 = "friends"
        client.kv.put(key, value0)
        success = client.kv.compare_and_swap(key, value: value1, previous_value: "ginger nut")
        success.should be_false
        client.kv.get(key).should eq value0
      end
    end

    describe "put_not_exists" do
      it "succeeds if no key present" do
        client = Etcd.from_env
        lease = client.lease.grant 5
        key = "#{TEST_PREFIX}/#{UUID.random}"
        value = "hello world"
        success = client.kv.put_not_exists(key, value: value, lease: lease.id)
        success.should be_true
        client.kv.get(key).should eq value
      end

      it "fails if a key is present" do
        client = Etcd.from_env
        key = "#{TEST_PREFIX}/#{UUID.random}"
        value0 = "hello world"
        value1 = "bye world"
        client.kv.put(key, value: value0)
        success = client.kv.put_not_exists(key, value: value1)
        success.should be_false
        client.kv.get(key).should eq value0
      end
    end

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

      client.kv.put(key0, value0, lease: lease.id)
      client.kv.put(key1, value1, lease: lease.id)
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
