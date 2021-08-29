require 'rails_helper'

describe TqlLoadFactory do
  subject { Load.last }

  let(:complete_load_data) {
    base_load_data.merge(load_data)
  }

  let(:load_data) {{}}

  before do
    allow(DistanceFromGoogle).to receive(:call).and_return(123)
    LoadBoard.create!(name: 'TQL')
    BrokerCompanyIdentifier.create!([
                                      load_board: LoadBoard.tql,
                                      broker_company: BrokerCompany.create!(name: 'TQL')
                                    ])

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

      it 'is retrieved from Google' do
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

  it "doesn't create duplicates when called again" do
    expect { described_class.call(complete_load_data) }.not_to change { Load.count }
  end

  def base_load_data
    {
      'PostIdReferenceNumber' => 'ABC123',
      'Weight' => 4567,
      'Origin' => {},
      'Miles' => 0,
      'Destination' => {},
      'LoadDate' => '08/26/2021 00:00:00',
      'DeliveryDate' => '08/26/2021 00:00:00',
      'Notes' => 'Foo bar baz'
    }
  end
end
