class LoadsController < ApplicationController
  def index
    @origin_location = City.first

    if valid_to_search?
      # Load.delete_all
      #
      # TruckersEdgeRefresh.call(
      #   origin_location: @origin_location,
      #   origin_date: origin_date,
      #   auth_token: params[:dat_auth_token]
      # )

      @loads = Load.all.includes(:broker_company).order(:pickup_date)
    end
  end

  def origin_date
    params[:origin_date]
    # Date.today
  end
  helper_method :origin_date

  private

  def valid_to_search?
    origin_date.present?
  end
end
