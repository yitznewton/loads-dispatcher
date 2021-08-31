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
  end

  it 'creates load identifier model' do
    expect(load.load_identifier.identifier).to eq('ABC123')
  end

  it 'sets broker company name' do
    expect(load.broker_company.to_s).to eq('TQL')
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
