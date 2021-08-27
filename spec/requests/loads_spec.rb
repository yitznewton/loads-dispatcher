require 'rails_helper'

RSpec.describe "Loads", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/loads/index"
      expect(response).to have_http_status(:success)
    end
  end

end
