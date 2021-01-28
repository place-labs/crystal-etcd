# crystal-etcd

[![Build Status](https://travis-ci.org/place-labs/crystal-etcd.svg?branch=master)](https://travis-ci.org/place-labs/crystal-etcd)
[![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://place-labs.github.io/crystal-etcd/)

[etcd](https://www.etcd.io/) client for [crystal lang](https://crystal-lang.org/) implemented as a thin wrapper over etcd's [gRPC-HTTP gateway](https://github.com/etcd-io/etcd/blob/master/Documentation/dev-guide/api_grpc_gateway.md).

This client was developed against etcd v3.3, to use a higher version, set `api_version` arg to an appropriate version prefix when instantiating the client.

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

- Auth.
- Multi-node.

### Auth

- [ ] authenticate
- [ ] disable
- [ ] enable
- [ ] role/add
- [ ] role/delete
- [ ] role/get
- [ ] role/grant
- [ ] role/list
- [ ] role/revoke
- [ ] user/add
- [ ] user/changepw
- [ ] user/delete
- [ ] user/get
- [ ] user/grant
- [ ] user/list
- [ ] user/revoke

### Cluster

- [ ] member/add
- [ ] member/list
- [ ] member/promote
- [ ] member/remove
- [ ] member/update

### Kv

- [x] put
- [x] range
- [x] deleterange
- [ ] compaction
- [ ] txn

### Lease

- [x] grant
- [x] keepalive
- [x] leases
- [x] revoke
- [x] timetolive

### Maintenance

- [ ] alarm
- [ ] defragment
- [ ] hash
- [ ] snapshot
- [x] status
- [ ] transfer-leadership

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
