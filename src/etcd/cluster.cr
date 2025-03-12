module Etcd::Cluster
  private getter client : Etcd::Client

  def initialize(@client = Etcd::Client.new)
  end

  # POST cluster/member/add
  def member_add(is_learner : Bool, peer_urls : Array(String))
    response = client.api.post("/cluster/member/add", {is_learner: is_learner, peerURLs: peer_urls}).body
    Model::Cluster::MemberAdd.from_json(response)
  end

  # POST cluster/member/list
  def member_list
    response = client.api.post("/cluster/member/list").body
    Model::Cluster::Members.from_json(response).members
  end

  # POST cluster/member/promote
  def member_promote(id : UInt64)
    response = client.api.post("/cluster/member/promote", {ID: id}).body
    Model::Cluster::Members.from_json(response).members
  end

  # POST cluster/member/remove
  def member_remove(id : UInt64)
    response = client.api.post("/cluster/member/remove", {ID: id}).body
    Model::Cluster::Members.from_json(response).members
  end

  # POST cluster/member/update
  def member_update(id : UInt64, peer_urls : Array(String))
    response = client.api.post("/cluster/member/update", {ID: id, peerURLs: peer_urls}).body
    Model::Cluster::Members.from_json(response).members
  end
end
