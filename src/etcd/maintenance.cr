require "./model/maintenance"

class Etcd::Maintenance
  private getter client : Etcd::Client

  def initialize(@client = Etcd::Client.new)
  end

  def alarm(action : Model::AlarmAction, alarm : Model::AlarmType, member_id : UInt64)
    response = client.api.post("/maintenance/alarm", {action: action, alarm: alarm, memberID: member_id}).body
    Model::Alarms.from_json(response).alarms
  end

  def defragment
    client.api.post("/maintenance/defragment").success?
  end

  def hash(revision : String)
    response = client.api.post("/maintenance/hash").body
    Model::Revision.from_json(response)
  end

  def snapshot
    model = Model::Snapshot.from_json(client.api.post("/maintenance/snapshot").body)
    raise Exception.new(model.error.not_nil!.to_s) if model.result.nil?
    model.result
  end

  # Queries status of etcd instance
  def status
    Model::Status.from_json(client.api.post("/maintenance/status").body)
  end

  # Queries for current leader of the etcd cluster
  def leader
    status.leader
  end

  def transfer_leadership(target_id : UInt64)
    client.api.post("/maintenance/transfer_leadership", {targetID: target_id}).success?
  end
end
