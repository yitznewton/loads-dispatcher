class LoadsController < ApplicationController
  def index
    @origin_location = City.first

    if valid_to_search?
      @loads = SearchLoads.call(
        origin_location: @origin_location,
        origin_date: origin_date
      ).sort_by { |l| l.pickup_date }
    end
  end

  def origin_date
    params[:origin_date]
  end
  helper_method :origin_date

  private

  def valid_to_search?
    origin_date.present?
  end
end
