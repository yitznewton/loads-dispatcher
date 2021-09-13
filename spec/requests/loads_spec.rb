require 'rails_helper'

describe 'Loads', type: :request do
  it 'displays shortlist' do
    get '/loads/shortlist'
    expect(response).to have_http_status(:ok)
  end

  describe 'clearing deleted from shortlist' do
    let!(:shortlisted_deleted_load) do
      create(:load, shortlisted_at: Time.current).tap do |l|
        l.load_identifier.update(deleted_at: Time.current)
      end
    end

    let!(:shortlisted_active_load) do
      create(:load, shortlisted_at: Time.current)
    end

    it 'redirects' do
      post '/loads/clear_deleted_from_shortlist'
      expect(response).to have_http_status(:redirect)
    end

    it 'clears only the deleted load from shortlist' do
      post '/loads/clear_deleted_from_shortlist'
      expect(shortlisted_deleted_load.reload).not_to be_shortlisted
      expect(shortlisted_active_load.reload).to be_shortlisted
    end
  end
end
