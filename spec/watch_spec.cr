require "./helper"

module Etcd
  describe Watch do
    it "watches a key" do
      ttl = 5_i64

      key = "#{TEST_PREFIX}/footy"
      values = ["a", "b", "c", "d", "e"]

      received = [] of Etcd::Model::WatchEvent
      watcher = Etcd.from_env.watch.watch(key) do |events|
        received += events
      end

      spawn { watcher.start }

      Fiber.yield

      client = Etcd.from_env
      values.each do |v|
        lease = client.lease.grant ttl
        client.kv.put(key, v, lease: lease[:id])
      end

      sleep 0.2

      received.size.should eq values.size
      received.map(&.kv.value).should eq values

      received.all? { |e| e.kv.key == key }.should be_true
      watcher.stop
    end

    it "watches a prefix" do
      ttl = 5_i64

      key0, value0 = "#{TEST_PREFIX}/foo", "bar"
      key1, value1 = "#{TEST_PREFIX}/foot", "bath"

      received = [] of Etcd::Model::WatchEvent
      watcher = Etcd.from_env.watch.watch_prefix(key0) do |events|
        received += events
      end

      begin
        spawn { watcher.start }
      rescue
      end

      client = Etcd.from_env
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

    describe Etcd::Watch::Filter do
      it "ignores put events with NOPUT" do
        ttl = 5_i64

        key0, value0 = "#{TEST_PREFIX}/foo", "bar"
        key1, value1 = "#{TEST_PREFIX}/foot", "bath"

        received = [] of Etcd::Model::WatchEvent
        watcher = Etcd.from_env.watch.watch_prefix(key0, filters: [Etcd::Watch::Filter::NOPUT]) do |events|
          received += events
        end

        begin
          spawn { watcher.start }
          Fiber.yield
        rescue
        end

        client = Etcd.from_env

        lease = client.lease.grant ttl
        client.kv.put(key0, value0, lease: lease[:id])
        client.kv.delete(key0)
        client.kv.put(key1, value1, lease: lease[:id])

        received.size.should eq 1

        watcher.stop
      end

      it "ignores delete events with NODELETE" do
        ttl = 5_i64

        key0, value0 = "#{TEST_PREFIX}/foo", "bar"
        key1, value1 = "#{TEST_PREFIX}/foot", "bath"

        received = [] of Etcd::Model::WatchEvent
        watcher = Etcd.from_env.watch.watch_prefix(key0, filters: [Etcd::Watch::Filter::NODELETE]) do |events|
          received += events
        end

        begin
          spawn { watcher.start }
          Fiber.yield
        rescue
        end

        client = Etcd.from_env
        lease = client.lease.grant ttl
        client.kv.put(key0, value0, lease: lease[:id])
        client.kv.put(key1, value1, lease: lease[:id])
        client.kv.delete(key0)

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
end
