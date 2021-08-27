class LoadsController < ApplicationController
  def index
    @origin_location = City.first
    @origin_date = Date.today
    @loads = SearchLoads.call(
      origin_location: @origin_location,
      origin_date: @origin_date
    )
  end
end
