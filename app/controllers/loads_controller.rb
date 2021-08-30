class LoadsController < ApplicationController
  def index
    @loads = Load.all.includes(:broker_company).order(:pickup_date)

    respond_to do |format|
      format.html
      format.json do
        render json: @loads
      end
    end
  end
end
