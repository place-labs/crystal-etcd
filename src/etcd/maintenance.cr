require "./model/maintenance"

class Etcd::Maintenance
  private getter api : Etcd::Api

  def initialize(@api = Etcd::Api.new)
  end

  # Queries status of etcd instance
  def status
    response_body = api.post("/maintenance/status").body
    Model::Status.from_json(response_body)
  end

  # Queries for current leader of the etcd cluster
  def leader
    status.leader
  end
end
