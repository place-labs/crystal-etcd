require "./helper"

describe Etcd do
  etcd_host = ENV["ETCD_HOST"]? || "127.0.0.1"
  etcd_port = (ENV["ETCD_PORT"]? || 2379).to_i32
  etcd_ttl = (ENV["ETCD_TTL"]? || 5).to_i64
  client = Etcd.client(etcd_host, etcd_port)

  describe "Cluster Status" do
    it "queries status of cluster" do
      keys = client.status.keys
      expected_keys = {:leader, :member_id, :version}
      keys.should eq expected_keys
    end

    it "queries leader" do
      leader = client.leader
      leader.should be_a UInt64
    end
  end

  describe "Leases" do
    it "requests a lease" do
      lease = client.lease_grant etcd_ttl

      lease[:ttl].should eq etcd_ttl
      lease.has_key?(:id).should be_true
    end

    it "queries ttl of lease" do
      lease = client.lease_grant etcd_ttl
      lease_ttl = client.lease_ttl lease[:id]

      lease_ttl[:ttl].should be <= etcd_ttl
    end

    it "queries active leases" do
      lease = client.lease_grant etcd_ttl
      active_leases = client.leases
      lease_present = active_leases.any? { |id| id == lease[:id] }

      lease_present.should be_true
    end

    it "revokes a lease" do
      lease = client.lease_grant etcd_ttl
      response = client.lease_revoke lease[:id]

      response.should be_true
    end

    it "extends a lease" do
      lease = client.lease_grant etcd_ttl
      new_ttl = client.lease_keep_alive lease[:id]

      new_ttl.should be > 0
    end
  end

  describe "Watch" do
  end

  describe "Key/Value" do
    test_prefix = "TEST"
    Spec.before_each do
      client.delete_prefix test_prefix
    end

    it "watches a prefix" do
      lease = client.lease_grant etcd_ttl
      events = [] of Etcd::Model::WatchEvent
      watcher = client.watch_prefix(test_prefix) do |event|
        events + event
      end

      spawn { watcher.start }

      key0, value0 = "#{test_prefix}/foo", "bar"
      key1, value1 = "#{test_prefix}/foot", "bath"

      client.put(key0, value0, lease: lease[:id])
      client.put(key1, value1, lease: lease[:id])
      puts events

      watcher.stop
    end

    it "sets a value" do
      response = client.put("#{test_prefix}/hello", "world")

      response.should be_true
    end

    it "queries a range of keys" do
      key, value = "#{test_prefix}/foo", "bar"
      client.put(key, value)
      range = client.range(key)

      present = range.any? { |r| r.key == key && r.value == value }
      present.should be_true
    end

    it "queries keys by prefix" do
      lease = client.lease_grant etcd_ttl
      key0, value0 = "#{test_prefix}/foo", "bar"
      key1, value1 = "#{test_prefix}/foot", "bath"

      client.put(key0, value0, lease: lease[:id])
      client.put(key1, value1, lease: lease[:id])
      range = client.range_prefix key0

      present = range.any? { |r| r.key == key1 && r.value == value1 }
      present.should be_true
    end
  end
end
