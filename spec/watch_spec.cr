require "./helper"

module Etcd
  describe Watch do
    it "watches a prefix" do
      client = Etcd.from_env
      ttl = 5_i64

      lease = client.lease.grant ttl
      events = [] of Etcd::Model::WatchEvent
      watcher = client.watch.watch_prefix(TEST_PREFIX) do |event|
        events + event
      end

      spawn { watcher.start }

      key0, value0 = "#{TEST_PREFIX}/foo", "bar"
      key1, value1 = "#{TEST_PREFIX}/foot", "bath"

      client.kv.put(key0, value0, lease: lease[:id])
      client.kv.put(key1, value1, lease: lease[:id])
      puts events

      watcher.stop
    end
  end
end
