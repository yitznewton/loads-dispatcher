class LoadsController < ApplicationController
  def index
    @loads = Load.active
                 .joins(:load_identifier).merge(LoadIdentifier.active)
                 .includes(:broker_company)
                 .where('pickup_date > ?', earliest_pickup)
                 .where('pickup_date < ?', latest_pickup)
                 .order(:pickup_date)

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

  def earliest_pickup
    (params[:earliest_pickup] || Time.current).to_time.beginning_of_day
  end
  helper_method :earliest_pickup

  def latest_pickup
    (params[:latest_pickup] || Time.current).to_time.end_of_day
  end
  helper_method :latest_pickup
end
