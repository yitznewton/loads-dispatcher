class LoadsController < ApplicationController
  protect_from_forgery except: %i[destroy shortlist]
  before_action :load_resources, only: %i[index shortlisted]
  before_action :load_resource, only: %i[show destroy shortlist unshortlist]
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
    @hide_maps = session[:hide_maps] = false
    redirect_back(fallback_location: loads_path)
  end

  def hide_maps
    @hide_maps = session[:hide_maps] = true
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

  def load_resources
    @loads = Load.includes(:broker_company).includes(:load_identifier).includes(:rates)
                 .order('loads.pickup_date, rates.id')
  end

  def load_resource
    @load = Load.find(params[:id])
  end

  def set_maps_from_session
    @hide_maps = session[:hide_maps]
  end
end
