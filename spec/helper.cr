require "spec"
require "../src/etcd"
require "../src/etcd/*"

TEST_PREFIX = "TEST"
Spec.before_each do
  begin
    Etcd.from_env.kv.delete_prefix TEST_PREFIX
  rescue e
  end
end
