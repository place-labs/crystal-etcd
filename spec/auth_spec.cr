require "uuid"
require "./helper"

# WARNING: Running this test could enable RBAC authentication on your etcd cluster
# and fail to turn it off if something goes wrong! In that case, you will have
# to manually turn RBAC off before running the tests again:
# etcdctl --user root --password YOUR_ROOT_PASSWORD auth disable

# TLDR: make sure you know the root username/password to your etcd cluster before running
# these tests! You have to have a root account set up before running them, btw, since a root
# account is required to enable authentication.

# Also, for the TLS test to pass, you need to make sure you're serving etcd over https with
# some sort of valid cert (e.g turn on auto-tls):
# ETCD_LISTEN_CLIENT_URLS=http://0.0.0.0:2379,https://0.0.0.0:2379
# ETCD_AUTO_TLS=true

module Etcd
  describe Auth do
    # this also tests authentication (it tests way too much stuff but it is all a chain of operations so...)
    describe "RBAC" do
      it "can be enabled and disabled" do
        client = Etcd.from_env
        client.auth.user_add(TEST_USER, TEST_PASSWORD)
        client.auth.user_grant(ROOT_ROLE, TEST_USER)

        # enable RBAC and confirm we can't do stuff anymore
        client.auth.enable
        expect_raises(Etcd::ApiError) do
          response = client.kv.put("#{TEST_PREFIX}/hello", "world")
        end

        # disable RBAC and confirm we can do stuff again
        client.set_username_password(TEST_USER, TEST_PASSWORD)
        client.auth.disable

        # clear credentials and make sure we can still do stuff
        client.set_username_password
        response = client.kv.put("#{TEST_PREFIX}/hello", "world")
        response.should be_a Model::Put
      end
    end

    describe "roles" do
      it "can be listed" do
        client = Etcd.from_env
        client.auth.role_list.should be_a Array(String)
      end

      it "can be added and deleted" do
        client = Etcd.from_env

        client.auth.role_add(TEST_ROLE)
        client.auth.role_list.should contain TEST_ROLE

        client.auth.role_delete(TEST_ROLE)

        client.auth.role_list.should_not contain TEST_ROLE
      end
    end

    describe "permissions" do
      it "can be granted" do
        client = Etcd.from_env
        client.auth.role_add(TEST_ROLE)

        client.auth.role_get(TEST_ROLE).empty?.should be_true

        client.auth.role_grant(TEST_ROLE, TEST_PREFIX)
        client.auth.role_get(TEST_ROLE).size.should eq 1

        client.auth.role_grant_prefix(TEST_ROLE, TEST_PREFIX)
        client.auth.role_get(TEST_ROLE).size.should eq 2

        client.auth.role_grant_prefix(TEST_ROLE, TEST_PREFIX, Model::PermissionType::WRITE)
        client.auth.role_get(TEST_ROLE).size.should eq 3
      end

      it "can be revoked" do
        client = Etcd.from_env
        client.auth.role_add(TEST_ROLE)

        client.auth.role_grant(TEST_ROLE, TEST_PREFIX)
        client.auth.role_revoke(TEST_ROLE, TEST_PREFIX)
        client.auth.role_get(TEST_ROLE).empty?.should be_true

        client.auth.role_grant_prefix(TEST_ROLE, TEST_PREFIX)
        client.auth.role_revoke_prefix(TEST_ROLE, TEST_PREFIX)
        client.auth.role_get(TEST_ROLE).empty?.should be_true
      end
    end

    describe "TLS" do
      it "can be used" do
        tls_context = OpenSSL::SSL::Context::Client.new
        tls_context.verify_mode = OpenSSL::SSL::VerifyMode::NONE

        client = Etcd::Client.new(url: URI.parse("https://localhost:2379"), tls_context: tls_context)
        response = client.kv.put("#{TEST_PREFIX}/hello", "world")
        response.should be_a Model::Put
      end
    end
  end
end
