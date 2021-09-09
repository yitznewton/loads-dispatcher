require 'rails_helper'

describe LoadsDataRefreshJob do
  include ActiveJob::TestHelper

  before do
    allow(CombinedRefresh).to receive(:call)
  end

  it 'calls a combined refresh' do
    described_class.perform_now(truckers_edge_auth_token: 'ABC123')

    expect(CombinedRefresh).to have_received(:call) do |kwargs|
      expect(kwargs.fetch(:truckers_edge_auth_token)).to eq('ABC123')
    end
  end

  describe 're-queuing the next refresh' do
    context 'when there was an error' do
      before do
        allow(CombinedRefresh).to receive(:call).and_raise(BadTruckersEdgeResponse)
      end

      it 'does not re-queue' do
        assert_no_enqueued_jobs do
          described_class.perform_now(truckers_edge_auth_token: 'ABC123')
        end
      end
    end

    context 'when there was success' do
      it 're-queues' do
        # rubocop:disable RSpec/DescribedClass
        assert_enqueued_with(job: LoadsDataRefreshJob, args: [{ truckers_edge_auth_token: 'ABC123'}]) do
          described_class.perform_now(truckers_edge_auth_token: 'ABC123')
        end
        # rubocop:enable RSpec/DescribedClass
      end
    end
  end
end
