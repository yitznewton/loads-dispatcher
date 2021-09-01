class ApplicationController < ActionController::Base
  AUTH_REALM = ENV['HTTP_AUTH_REALM']

  before_action :authenticate if Rails.env.production?

  private

  def authenticate
    authenticate_or_request_with_http_digest(AUTH_REALM) do
      ENV['AUTH_PASSWORD_DIGEST']
    end
  end
end
