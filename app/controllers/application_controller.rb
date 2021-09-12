class ApplicationController < ActionController::Base
  before_action :authenticate if Rails.env.production?

  private

  def authenticate
    authenticate_or_request_with_http_basic do
      ENV['AUTH_PASSWORD']
    end
  end
end
