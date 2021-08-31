require 'rails_helper'

describe TqlLoadFactory do
  subject(:load) { Load.last }

  let(:complete_load_data) {
    base_load_data.merge(load_data)
  }

  let(:load_data) {{}}

  before do
    allow(DistanceFromGoogle).to receive(:call).and_return(123)
    allow(CoordinatesFromGoogle).to receive(:call).and_return(nil)
    LoadBoard.create!(name: 'TQL')
    BrokerCompanyIdentifier.create!([
                                      load_board: LoadBoard.tql,
                                      broker_company: BrokerCompany.create!(name: 'TQL')
                                    ])

    described_class.call(complete_load_data)
  end

  describe 'distance' do
    context 'when given' do
      let(:load_data) {{
        'Miles' => 100
      }}

      it 'is used' do
        expect(load.distance).to eq(100)
      end
    end

    context 'when missing' do
      let(:load_data) {{
        'Miles' => 0
      }}

      it 'is retrieved from Google using the expected place names' do  # rubocop:disable RSpec/MultipleExpectations
        expect(load.distance).to eq(123)
        expect(DistanceFromGoogle).to have_received(:call).with(origin: 'Passaic, NJ', destination: 'West Hartford, CT')
      end
    end
  end

  it 'extracts broker company name' do
    expect(load.broker_company.to_s).to eq('TQL')
  end

  it 'creates load identifier model' do
    expect(load.load_identifier.identifier).to eq('ABC123')
  end

  describe 'updating' do
    context 'with invalid data' do
      it "doesn't create a LoadIdentifier" do
        updated_data = complete_load_data.merge('Weight' => 0)
        expect { described_class.call(updated_data) }.not_to(change { LoadIdentifier.count })
      end

      it "doesn't update the load" do
        updated_data = complete_load_data.merge('Weight' => 0)
        expect { described_class.call(updated_data) }.not_to(change { load.rate })
      end

      it 'removes the load' do
        updated_data = complete_load_data.merge('Weight' => 0)
        described_class.call(updated_data)
        expect(Load.active.count).to eq(0)
      end
    end

    it 'updates the load' do
      updated_data = complete_load_data.merge('Weight' => 8000)
      described_class.call(updated_data)
      expect(load.weight).to eq(8000)
    end

    it "doesn't create duplicates" do
      expect { described_class.call(complete_load_data) }.not_to(change { Load.count })
    end
  end

  describe 'raw data' do
    it 'is attached to the load' do
      expect(load.raw).to eq(complete_load_data)
    end

    it 'is a new associated model' do
      expect(RawLoad.find_by(load: load).data).to eq(complete_load_data)
    end
  end

  def base_load_data
    {
      'PostIdReferenceNumber' => 'ABC123',
      'Weight' => 4567,
      'Origin' => {'City' => 'Passaic', 'StateCode' => 'NJ'},
      'Destination' => {'City' => 'West Hartford', 'StateCode' => 'CT'},
      'Miles' => 100,
      'LoadDate' => '08/26/2021 00:00:00',
      'DeliveryDate' => '08/26/2021 00:00:00',
      'Notes' => 'Foo bar baz'
    }
  end
end
