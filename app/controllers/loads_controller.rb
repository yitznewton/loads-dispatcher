class LoadsController < ApplicationController
  def index
    @loads = Load.all.includes(:broker_company).order(:pickup_date)
  end
end
