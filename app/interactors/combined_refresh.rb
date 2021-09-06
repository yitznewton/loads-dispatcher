class CombinedRefresh
  def self.call(origin_date:, truckers_edge_auth_token:)
    TqlRefresh.call(origin_date: origin_date)
    TruckersEdgeRefresh.call(origin_date: origin_date, auth_token: truckers_edge_auth_token)
  end
end
