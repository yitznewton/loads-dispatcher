# rubocop:disable Metrics/ClassLength
class LoadsController < ApplicationController
  protect_from_forgery except: %i[update destroy shortlist]
  before_action :load_resources, only: %i[index shortlisted]
  before_action :load_refresh_status, only: %i[index shortlisted]
  before_action :load_resource, only: %i[show update destroy shortlist unshortlist]
  before_action :set_maps_from_session

  def index
    @loads = @loads.active
    @loads = @loads.where('pickup_date > ?', earliest_pickup) if earliest_pickup
    @loads = @loads.where('pickup_date < ?', latest_pickup) if latest_pickup

    respond_to do |format|
      format.html

      format.json do
        render json: @loads
      end
    end
  end

  def shortlisted
    @loads = @loads.shortlisted

    respond_to do |format|
      format.html do
        render 'index'
      end

      format.json do
        render json: @loads
      end
    end
  end

  def show
  end

  def update
    if @load.update(load_params)
      head :ok
    else
      head :bad_request
    end
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

  def show_maps
    @show_maps = session[:show_maps] = true
    redirect_back(fallback_location: loads_path)
  end

  def hide_maps
    @show_maps = session[:show_maps] = false
    redirect_back(fallback_location: loads_path)
  end

  def clear_deleted_from_shortlist
    Load.deleted.unshortlist_all
    redirect_back(fallback_location: shortlist_loads_path)
  end

  def earliest_pickup
    params[:earliest_pickup].presence&.to_time&.beginning_of_day
  end
  helper_method :earliest_pickup

  def latest_pickup
    params[:latest_pickup].presence&.to_time&.end_of_day
  end
  helper_method :latest_pickup

  def shortlist?
    action_name == 'shortlisted'
  end
  helper_method :shortlist?

  private

  def load_params
    params.require(:load).permit(:rate)
  end

  def load_resources
    @loads = Load.includes(:broker_company)
                 .includes(:load_identifier)
                 .includes(:rates)
                 .order('loads.pickup_date', 'rates.id')
  end

  def load_resource
    @load = Load.find(params[:id])
  end

  def load_refresh_status
    @refresh_status = RefreshStatus.current
  end

  def set_maps_from_session
    @show_maps = session[:show_maps]
  end
end
# rubocop:enable Metrics/ClassLength
