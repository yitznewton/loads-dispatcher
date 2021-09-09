class LoadsDataRefreshJob < ApplicationJob
  discard_on BadTqlResponse, BadTruckersEdgeResponse

  def perform(truckers_edge_auth_token:)
    CombinedRefresh.call(origin_date: Time.current, truckers_edge_auth_token: truckers_edge_auth_token)

    self.class.set(wait: waiting_period).perform_later(truckers_edge_auth_token: truckers_edge_auth_token)
  end

  def waiting_period
    rand(40..360).seconds
  end
end
