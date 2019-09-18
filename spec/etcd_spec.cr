require "./helper"

describe Etcd do
  it "#from_env" do
    Etcd.from_env.should be_a Etcd::Client
  end
end
