require 'rails_helper'

describe TqlLoadFactory do
  subject { Load.last }

  let(:complete_load_data) {
    base_load_data.merge(load_data)
  }

  let(:load_data) {{}}
  let(:before_call) { -> {} }

  before do
    allow(DistanceFromGoogle).to receive(:call).and_return(123)
    LoadBoard.create!(name: 'TQL')
    BrokerCompanyIdentifier.create!([
                                      load_board: LoadBoard.tql,
                                      broker_company: BrokerCompany.create!(name: 'TQL')
                                    ])

    before_call.call
    described_class.call(complete_load_data)
  end

  describe 'distance' do
    context 'where given' do
      let(:load_data) {{
        'Miles' => 100
      }}

      it 'is used' do
        expect(subject.distance).to eq(100)
      end
    end

    context 'where missing' do
      let(:load_data) {{
        'Miles' => 0
      }}

      let(:before_call) { -> {
        expect(DistanceFromGoogle).to receive(:call).with(origin: 'Passaic, NJ', destination: 'West Hartford, CT')
                                                    .and_return(123)
      } }

      it 'is retrieved from Google using the expected place names' do
        expect(subject.distance).to eq(123)
      end
    end
  end

  it 'extracts broker company name' do
    expect(subject.broker_company.to_s).to eq('TQL')
  end

  it 'creates load identifier model' do
    expect(subject.load_identifier.identifier).to eq('ABC123')
  end

  context 'when called again' do
    context 'with valid data' do
      it 'updates the existing record when called again' do
        described_class.call(complete_load_data.merge('Notes' => 'Bongo'))
        expect(subject.notes).to eq('Bongo')
        expect(Load.count).to eq(1)
      end
    end

    context 'with invalid data' do
      it 'destroys the load model' do
        described_class.call(complete_load_data.merge('Notes' => 'no box trucks'))
        expect(Load.count).to eq(0)
      end
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
