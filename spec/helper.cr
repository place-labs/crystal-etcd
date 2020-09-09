require "spec"
require "../src/etcd"
require "../src/etcd/*"

TEST_PREFIX = "test"

Spec.before_suite do
  Log.setup("*", level: Log::Severity::Debug)
end

Spec.before_each do
  begin
    Etcd.from_env.kv.delete_prefix TEST_PREFIX
  rescue e
  end
end
