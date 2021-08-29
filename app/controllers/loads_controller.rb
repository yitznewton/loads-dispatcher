class LoadsController < ApplicationController
  def index
    @origin_location = City.first

    @loads = Load.all.includes(:broker_company).order(:pickup_date)
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
