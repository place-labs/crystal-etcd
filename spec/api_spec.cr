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
  describe Api do
    it "should retry when it can't connect to a bad endpoint" do
      client = Etcd::Client.new(
        endpoints: [
          URI.parse(NONEXISTENT_ENDPOINT),
          URI.parse("http://localhost:2379"),
        ]
      )

      client.kv.put("#{TEST_PREFIX}_endpoint_test", "yup")
    end

    it "should retry when it a previously good endpoint fails" do
      client = Etcd::Client.new(
        endpoints: [
          URI.parse("http://localhost:2379"),
          URI.parse(NONEXISTENT_ENDPOINT),
        ]
      )

      client.kv.put("#{TEST_PREFIX}_endpoint_test", "before_failure")

      client.api.rotate_endpoints

      client.kv.put("#{TEST_PREFIX}_endpoint_test", "after_failure")
    end

    it "should reset the retry count a successful request is made" do
      client = Etcd::Client.new(
        endpoints: [
          URI.parse(NONEXISTENT_ENDPOINT),
          URI.parse("http://localhost:2379"),
        ]
      )

      client.kv.get("#{TEST_PREFIX}_endpoint_test")

      client.api.retries_performed.should eq 0
    end

    it "should bail out with a connection error if a single endpoint fails" do
      client = Etcd::Client.new(URI.parse(NONEXISTENT_ENDPOINT))

      expect_raises(Etcd::ConnectionError) do
        client.kv.get("#{TEST_PREFIX}_endpoint_test")
      end
    end

    it "should bail out with a connection error if all endpoints fail" do
      client = Etcd::Client.new(
        endpoints: [
          URI.parse(NONEXISTENT_ENDPOINT),
          URI.parse(NONEXISTENT_ENDPOINT),
        ]
      )

      expect_raises(Etcd::ConnectionError) do
        client.kv.get("#{TEST_PREFIX}_endpoint_test")
      end
    end
  end
end
