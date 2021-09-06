class LoadsDataRefreshJob < ApplicationJob
  def perform(truckers_edge_auth_token:)
    CombinedRefresh.call(origin_date: Time.current, truckers_edge_auth_token: truckers_edge_auth_token)
  end
end
