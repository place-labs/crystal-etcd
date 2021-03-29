require "./helper"

module Etcd
  describe Lease do
    it "requests a lease" do
      ttl = 5_i64
      lease = Etcd.from_env.lease.grant ttl

      lease.ttl.should eq ttl
      (!!lease.id).should be_true
    end

    it "queries ttl of lease" do
      client = Etcd.from_env
      ttl = 5_i64

      lease = client.lease.grant ttl
      lease_ttl = client.lease.timetolive lease.id

      lease_ttl.ttl.should be <= ttl
    end

    it "queries active leases" do
      client = Etcd.from_env
      ttl = 5_i64

      lease = client.lease.grant ttl
      active_leases = client.lease.leases
      lease_present = active_leases.any?(&.==(lease.id))

      lease_present.should be_true
    end

    it "revokes a lease" do
      client = Etcd.from_env
      ttl = 5_i64

      lease = client.lease.grant ttl
      response = client.lease.revoke lease.id

      response.should be_true
    end

    it "extends a lease" do
      client = Etcd.from_env
      ttl = 5_i64

      lease = client.lease.grant ttl
      new_ttl = client.lease.keep_alive lease.id

      new_ttl.not_nil!.should be > 0
    end

    it "handles nil on keep_alive" do
      # Deserialise and handle incorrect json
      Etcd::Model::KeepAlive.from_json(%({"result": {"TTL": "15"}})).result.should eq(15)
      expect_raises(klass: JSON::SerializableError, message: "JSON key not found: TTL") {
        Etcd::Model::KeepAlive.from_json(%({"result": {"error": "error"}}))
      }

      client = Etcd.from_env
      new_ttl = client.lease.keep_alive 5_i64
      new_ttl.should be_nil
    end
  end
end
