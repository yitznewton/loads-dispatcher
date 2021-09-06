require 'rails_helper'

describe LoadsDataRefreshJob do
  before do
    allow(CombinedRefresh).to receive(:call)
  end

  it 'calls a combined refresh' do
    described_class.perform_now(truckers_edge_auth_token: 'ABC123')

    expect(CombinedRefresh).to have_received(:call) do |kwargs|
      expect(kwargs.fetch(:truckers_edge_auth_token)).to eq('ABC123')
    end
  end
end
