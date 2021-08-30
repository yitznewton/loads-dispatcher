class LoadsController < ApplicationController
  def index
    @loads = Load.active
                 .joins(:load_identifier).merge(LoadIdentifier.active)
                 .includes(:broker_company).order(:pickup_date)

    respond_to do |format|
      format.html
      format.json do
        render json: @loads
      end
    end
  end

  def destroy
    Load.find(params[:id]).dismiss!
  end
end
