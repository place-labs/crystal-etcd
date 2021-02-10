require "./model/maintenance"

class Etcd::Maintenance
  private getter client : Etcd::Client

  def initialize(@client = Etcd::Client.new)
  end

  # Queries status of etcd instance
  def status
    Model::Status.from_json(client.api.post("/maintenance/status").body)
  end

  # Queries for current leader of the etcd cluster
  def leader
    status.leader
  end
end
