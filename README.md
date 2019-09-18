# crystal-etcd

[etcd](https://www.etcd.io/) client for [crystal lang](https://crystal-lang.org/) implemented as a thin wrapper over etcd's gRPC-HTTP gateway.

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

## Contributing

1. [Fork it](https://github.com/aca-labs/crystal-etcd/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## See Also

- [crystal-docker](https://github.com/aca-labs/crystal-docker)

## Contributors

- [Caspian Baska](https://github.com/caspiano) - creator and maintainer
