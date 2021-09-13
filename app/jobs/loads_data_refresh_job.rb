class LoadsDataRefreshJob
  QUEUE_NAME = :loads_data_refresh

  def self.enqueue(truckers_edge_auth_token:)
    cancel_existing
    Delayed::Job.enqueue(new(truckers_edge_auth_token))
  end

  def initialize(truckers_edge_auth_token)
    @truckers_edge_auth_token = truckers_edge_auth_token
  end

  attr_reader :truckers_edge_auth_token

  def perform
    CombinedRefresh.call(origin_date: Time.current, truckers_edge_auth_token: truckers_edge_auth_token)
    requeue
  rescue BadTqlResponse, BadTruckersEdgeResponse
    # ignore and don't requeue
  end

  def queue_name
    QUEUE_NAME
  end

  def self.cancel_existing
    Delayed::Job.where(queue: QUEUE_NAME).delete_all
  end

  private

  def requeue
    # don't requeue if another job has been queued, presumably with a fresh auth token
    return if Delayed::Job.where(queue: QUEUE_NAME).count > 1

    Delayed::Job.enqueue(self, run_at: waiting_period.from_now)
  end

  def waiting_period
    rand(40..360).seconds
  end
end
