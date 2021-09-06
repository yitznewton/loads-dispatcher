require 'rails_helper'

describe CombinedRefresh do
  before do
    allow(TqlRefresh).to receive(:call)
    allow(TruckersEdgeRefresh).to receive(:call)
  end

  let(:origin_date) { Time.current }
  let(:truckers_edge_auth_token) { 'ABC123' }

  it 'calls the TQL refresh' do
    described_class.call(origin_date: origin_date, truckers_edge_auth_token: truckers_edge_auth_token)
    expect(TqlRefresh).to have_received(:call).with(origin_date: origin_date)
  end

  it 'calls the TruckersEdge refresh' do
    described_class.call(origin_date: origin_date, truckers_edge_auth_token: truckers_edge_auth_token)
    expect(TruckersEdgeRefresh).to have_received(:call)
      .with(origin_date: origin_date, auth_token: truckers_edge_auth_token)
  end
end
