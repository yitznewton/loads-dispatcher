class RefreshesController < ApplicationController
  def show
  end

  def create
    return head :bad_request unless truckers_edge_auth_token

    LoadsDataRefreshJob.enqueue(truckers_edge_auth_token: truckers_edge_auth_token)
    head :accepted
  end

  private

  def truckers_edge_auth_token
    params[:truckers_edge_auth_token]
  end
end
