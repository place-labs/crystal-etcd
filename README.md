# crystal-etcd

[etcd](https://www.etcd.io/) client for [crystal lang](https://crystal-lang.org/) implemented as a thin wrapper over the gRPC-HTTP ETCD gateway.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     etcd:
       github: aca-labs/crystal-etcd
   ```

2. Run `shards install`

## Usage

```crystal
require "etcd"
```

## TODO

### Auth

- [ ] POST auth/authenticate
- [ ] POST auth/disable
- [ ] POST auth/enable
- [ ] POST auth/role/add
- [ ] POST auth/role/delete
- [ ] POST auth/role/get
- [ ] POST auth/role/grant
- [ ] POST auth/role/list
- [ ] POST auth/role/revoke
- [ ] POST auth/user/add
- [ ] POST auth/user/changepw
- [ ] POST auth/user/delete
- [ ] POST auth/user/get
- [ ] POST auth/user/grant
- [ ] POST auth/user/list
- [ ] POST auth/user/revoke

### Cluster

- [ ] POST cluster/member/add
- [ ] POST cluster/member/list
- [ ] POST cluster/member/promote
- [ ] POST cluster/member/remove
- [ ] POST cluster/member/update

### KV

- [ ] POST /kv/compaction
- [ ] POST /kv/deleterange
- [ ] POST /kv/lease/leases
- [ ] POST /kv/lease/revoke
- [ ] POST /kv/lease/timetolive
- [~] POST /kv/put
- [~] POST /kv/range
- [ ] POST /kv/txn

### Lease

- [~] POST /lease/grant
- [~] POST /lease/keepalive
- [~] POST /lease/leases
- [~] POST /lease/revoke
- [~] POST /lease/timetolive

### Maintenance

- [ ] POST /maintenance/alarm
- [ ] POST /maintenance/defragment
- [ ] POST /maintenance/hash
- [ ] POST /maintenance/snapshot
- [~] POST /maintenance/status
- [ ] POST /maintenance/transfer-leadership

### Watch

## Contributing

1. [Fork it](https://github.com/aca-labs/crystal-etcd/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Caspian Baska](https://github.com/caspiano) - creator and maintainer
