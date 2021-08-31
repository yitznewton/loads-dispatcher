class LoadsController < ApplicationController
  protect_from_forgery except: %i[destroy shortlist]
  before_action :load_resource, only: %i[show destroy shortlist unshortlist]

  # rubocop:disable Metrics/MethodLength
  def index
    @loads = Load.active
                 .includes(:broker_company)
                 .where('pickup_date > ?', earliest_pickup)
                 .where('pickup_date < ?', latest_pickup)
                 .order(:pickup_date)

    @loads = @loads.shortlisted if shortlist?

    respond_to do |format|
      format.html
      format.json do
        render json: @loads
      end
    end
  end
  # rubocop:enable Metrics/MethodLength

  def show
  end

  def destroy
    @load.dismiss!

    respond_to do |format|
      format.json do
        head :ok
      end
      format.html do
        redirect_to loads_path
      end
    end
  end

  def shortlist
    @load.update!(shortlisted_at: Time.current)

    respond_to do |format|
      format.json do
        head :ok
      end
    end
  end

  def unshortlist
    @load.update!(shortlisted_at: nil)

    respond_to do |format|
      format.json do
        head :ok
      end
    end
  end

  def earliest_pickup
    (params[:earliest_pickup].presence || Time.current).to_time.beginning_of_day
  end
  helper_method :earliest_pickup

  def latest_pickup
    (params[:latest_pickup].presence || Time.current).to_time.end_of_day
  end
  helper_method :latest_pickup

  def shortlist?
    params[:shortlisted].present?
  end
  helper_method :shortlist?

  private

  def load_resource
    @load = Load.find(params[:id])
  end
end
