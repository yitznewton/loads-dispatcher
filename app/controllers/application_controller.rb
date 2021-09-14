class ApplicationController < ActionController::Base
  before_action :authenticate if Rails.env.production?
  before_action :authorize_profiler

  private

  def authenticate
    authenticate_or_request_with_http_basic do
      ENV['AUTH_PASSWORD']
    end
  end

  def authorize_profiler
    Rack::MiniProfiler.authorize_request
  end
end
