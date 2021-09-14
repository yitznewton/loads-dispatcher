require 'rails_helper'

describe LoadsDataRefreshJob do
  before do
    allow(CombinedRefresh).to receive(:call)
  end

  context 'when the refresh succeeds' do
    it 'records the status' do
      Meta.delete_all

      described_class.enqueue(truckers_edge_auth_token: 'ABC123')
      Delayed::Job.last.invoke_job

      expect(RefreshStatus.current).to be_success
      expect(RefreshStatus.current).not_to be_error
    end
  end

  context 'when the refresh fails' do
    before do
      allow(CombinedRefresh).to receive(:call).and_throw(exception)
    end

    let(:exception) { BadTruckersEdgeResponse.new('error' => 'Bad token') }

    it 'records the status' do
      Meta.delete_all

      described_class.enqueue(truckers_edge_auth_token: 'ABC123')
      begin
        Delayed::Job.last.invoke_job
      rescue Exception # rubocop:disable Lint/RescueException,Lint/SuppressedException
      end

      expect(RefreshStatus.current).not_to be_success
      expect(RefreshStatus.current).to be_error
      expect(RefreshStatus.current.error).to include(exception.message)
    end
  end
end
