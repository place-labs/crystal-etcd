require "./helper"

module Etcd
  describe Watch do
    it "watches a prefix" do
      client = Etcd.from_env
      ttl = 5_i64

      lease = client.lease.grant ttl
      received = [] of Etcd::Model::WatchEvent
      watcher = client.watch.watch_prefix(TEST_PREFIX) do |events|
        received + events
      end

      spawn { watcher.start }

      key0, value0 = "#{TEST_PREFIX}/foo", "bar"
      key1, value1 = "#{TEST_PREFIX}/foot", "bath"

      client.kv.put(key0, value0, lease: lease[:id])
      client.kv.put(key1, value1, lease: lease[:id])

      sleep 2

      puts received
      pp! client.kv.range(TEST_PREFIX)
      received.size.should eq 2
      watcher.stop
    end
  end
end
