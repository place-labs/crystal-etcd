# crystal-etcd

[![CI](https://github.com/place-labs/crystal-etcd/actions/workflows/ci.yml/badge.svg)](https://github.com/place-labs/crystal-etcd/actions/workflows/ci.yml)

[etcd](https://www.etcd.io/) client for [crystal lang](https://crystal-lang.org/) implemented as a thin wrapper over etcd's [gRPC-HTTP gateway](https://github.com/etcd-io/etcd/blob/master/Documentation/dev-guide/api_grpc_gateway.md).

The minimum supported etcd version is `3.4`.

## Installation

1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
  etcd:
    github: place-labs/crystal-etcd
```

2. Run `shards install`

## Usage

```crystal
require "etcd"

# Initialising a client from ETCD_HOST and ETCD_PORT
client = Etcd.from_env

# Add a key/value to etcd
client.kv.put("/service/hello", "world")
# Grab a key/value from etcd
client.range("/service/hello").kvs.try(&.first?) #=> #<Etcd::Model::KV @key="/service/hello" @value="world" @create_revision=nil  @mod_revision=nil @version=nil @lease=nil>
```

## TODO

- Specs (auth, cluster, maintenance, kv.compaction, kv.txn)
- Multi-node.
- Use enum instead of String

### Auth

- [x] authenticate
- [x] disable
- [x] enable
- [x] role/add
- [x] role/delete
- [x] role/get
- [x] role/grant
- [x] role/list
- [x] role/revoke
- [x] user/add
- [x] user/changepw
- [x] user/delete
- [x] user/get
- [x] user/grant
- [x] user/list
- [x] user/revoke

### Cluster

- [x] member/add
- [x] member/list
- [x] member/promote
- [x] member/remove
- [x] member/update

### Kv

- [x] put
- [x] range
- [x] deleterange
- [x] compaction
- [x] txn

### Lease

- [x] grant
- [x] keepalive
- [x] leases
- [x] revoke
- [x] timetolive

### Maintenance

- [x] alarm
- [x] defragment
- [x] hash
- [x] snapshot
- [x] status
- [x] transfer-leadership

### Watch

- [x] watch

## Contributing

1. [Fork it](https://github.com/place-labs/crystal-etcd/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## See Also

- [crystal-docker](https://github.com/place-labs/crystal-docker)

## Contributors

- [Caspian Baska](https://github.com/caspiano) - creator and maintainer
- [Duke Nguyen](https://github.com/dukeraphaelng) - maintainer