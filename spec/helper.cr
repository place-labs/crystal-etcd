require "spec"
require "../src/etcd"
require "../src/etcd/*"

TEST_PREFIX = "test"
TEST_ROLE = "#{TEST_PREFIX}_role"
TEST_USER = "#{TEST_PREFIX}_user"
TEST_PASSWORD = "#{TEST_PREFIX}_password"
ROOT_ROLE = "root"  # special unicorn root etcd role

Spec.before_suite do
  Log.setup("*", level: Log::Severity::Debug)
end

Spec.before_each do
  begin
    client = Etcd.from_env

    client.kv.delete_prefix TEST_PREFIX

    client.auth.user_list.select{|u| u.starts_with?(TEST_PREFIX) }.each do |test_user|
      client.auth.user_delete(test_user)
    end

    puts client.auth.role_list.inspect

    client.auth.role_list.select{|r| r.starts_with?(TEST_PREFIX) }.each do |test_role|
      client.auth.role_delete(test_role)
    end
  rescue
  end
end
