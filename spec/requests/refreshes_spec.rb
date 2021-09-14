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

      it 'enqueues new a combined refresh job' do
        allow(Delayed::Job).to receive(:enqueue).and_call_original

        post '/refresh.json', params: { truckers_edge_auth_token: 'ABC123' }

        expect(Delayed::Job).to have_received(:enqueue) do |job|
          expect(job.truckers_edge_auth_token).to eq('ABC123')
        end

        expect(Delayed::Job.where(queue: LoadsDataRefreshJob::QUEUE_NAME).count).to eq(1)
      end

      it 'clears any existing refresh job' do
        post '/refresh.json', params: { truckers_edge_auth_token: 'ABC123' }
        post '/refresh.json', params: { truckers_edge_auth_token: 'XYZ987' }

        expect(Delayed::Job.where(queue: LoadsDataRefreshJob::QUEUE_NAME).count).to eq(1)
      end

      it 'does not affect jobs in other queues' do
        '123'.delay(queue: :default).reverse

        post '/refresh.json', params: { truckers_edge_auth_token: 'XYZ987' }

        expect(Delayed::Job.where(queue: :default).count).to eq(1)
      end
    end
  end
end
