require "./models"

module Etcd::Metadata
  # Queries status of etcd instance
  def status
    response_body = post("/maintenance/status").body
    status = Model::Status.from_json(response_body)
    {
      leader:    status.leader,
      member_id: status.header.try(&.member_id),
      version:   status.version,
    }
  end

  # Queries for current leader of the etcd cluster
  def leader
    status[:leader]
  end
end
