require "./helper"

module Etcd
  describe Maintenance do
    it "queries status of cluster" do
      client = Etcd.from_env

      status = client.maintenance.status
      status.should_not be_nil
      status.leader.should be_a UInt64
      status.header.member_id.should be_a String
      status.version.should be_a String
    end

    it "queries leader" do
      client = Etcd.from_env

      leader = client.maintenance.leader
      leader.should be_a UInt64
    end
  end
end
