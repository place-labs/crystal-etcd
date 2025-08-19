require "uuid"
require "./helper"

# WARNING: Running this test could enable RBAC authentication on your etcd cluster
# and fail to turn it off if something goes wrong! In that case, you will have
# to manually turn RBAC off before running the tests again:
# etcdctl --user root --password YOUR_ROOT_PASSWORD auth disable

# TLDR: make sure you know the root username/password to your etcd cluster before running
# these tests! You have to have a root account set up before running them, btw, since a root
# account is required to enable authentication.

# IMPORTANT: to use this somewhat odd test, you have to start ETCD with - "ETCD_AUTH_TOKEN_TTL=2"
# If you don't then this test will "pass" without actually testing anything.
# To confirm that it worked, you can run etcd in debug mode and watch for the "deleted a simple token"
# message while this test is sleeping - also, in the test logs you should see a
# "Attempting to re-authenticate after HTTP 401" debug-level message.

module Etcd
  describe Client do
    describe "auth token" do
      it "can be rotated" do
        client = Etcd.from_env
        client.auth.user_add(TEST_USER, TEST_PASSWORD)
        client.auth.user_grant(ROOT_ROLE, TEST_USER)

        # enable RBAC and confirm we can't do stuff anymore
        client.auth.enable
        client.set_username_password(TEST_USER, TEST_PASSWORD)

        value = "world"

        response = client.kv.put("#{TEST_PREFIX}/hello", value)

        sleep Time::Span.new(seconds: 3) # wait for the token to expire (twice as long as ETCD_AUTH_TOKEN_TTL to be safe)

        # this should fail unless we refresh the token
        client.kv.get("#{TEST_PREFIX}/hello").should eq value

        # make sure to disable again
        client.auth.disable
      end
    end
  end
end
