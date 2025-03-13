require "./helper"

describe Etcd do
  it "#from_env" do
    Etcd.from_env.should be_a Etcd::Client
  end

  it "should take list of endpoints" do
    client = Etcd::Client.new(
      endpoints: [
        URI.parse(NONEXISTENT_ENDPOINT),
        URI.parse("http://localhost:2379"),
      ]
    )
  end
end
