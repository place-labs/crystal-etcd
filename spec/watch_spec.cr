require "./helper"

module Etcd
  describe Watch do
    it "watches a prefix" do
      client = Etcd.from_env
      ttl = 5_i64

      key0, value0 = "#{TEST_PREFIX}/foo", "bar"
      key1, value1 = "#{TEST_PREFIX}/foot", "bath"

      received = [] of Etcd::Model::WatchEvent
      watcher = client.watch.watch_prefix(key0) do |events|
        received += events
      end

      begin
        spawn { watcher.start }
      rescue
      end
      lease = client.lease.grant ttl
      client.kv.put(key0, value0, lease: lease[:id])
      client.kv.put(key1, value1, lease: lease[:id])

      sleep 0.25

      received.size.should eq 2
      first, second = received

      first.kv.key.should eq key0
      first.kv.value.should eq value0

      second.kv.key.should eq key1
      second.kv.value.should eq value1

      watcher.stop
    end
  end
end
