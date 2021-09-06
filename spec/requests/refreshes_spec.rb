require 'rails_helper'

describe 'Refreshes', type: :request do
  describe 'request page' do
    it 'returns OK status' do
      get '/refresh'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'making a request refresh' do
    context 'with bad params' do
      it 'returns BAD REQUEST status' do
        post '/refresh.json', params: { foo: 'bar' }
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'with good params' do
      it 'returns ACCEPTED status' do
        post '/refresh.json', params: { truckers_edge_auth_token: 'ABC123' }
        expect(response).to have_http_status(:accepted)
      end

      it 'enqueues a combined refresh job' do
        assert_enqueued_with(job: LoadsDataRefreshJob, args: [{truckers_edge_auth_token: 'ABC123'}]) do
          post '/refresh.json', params: { truckers_edge_auth_token: 'ABC123' }
        end
      end
    end
  end
end
