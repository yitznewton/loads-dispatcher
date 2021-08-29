require 'rails_helper'

describe TruckersEdgeLoadFactory do
  subject(:load) { Load.last }

  let(:complete_load_data) {
    base_load_data.merge(load_data)
  }

  let(:load_data) {{}}

  before do
    allow(DistanceFromGoogle).to receive(:call).and_return(123)
    LoadBoard.create!(name: 'Truckers Edge')

    described_class.call(complete_load_data)
  end

  describe 'distance' do
    context 'when given in surface miles' do
      let(:load_data) {{
        'isTripMilesAir' => false,
        'tripMiles' => 100
      }}

      it 'is used' do
        expect(load.distance).to eq(100)
      end
    end

    context 'when given in air miles' do
      let(:load_data) {{
        'isTripMilesAir' => true,
        'tripMiles' => 100
      }}

      it 'is retrieved from Google' do  # rubocop:disable RSpec/MultipleExpectations
        expect(load.distance).to eq(123)
        expect(DistanceFromGoogle).to have_received(:call).with(origin: 'Passaic, NJ', destination: 'West Hartford, CT')
      end
    end

    context 'when missing' do
      let(:load_data) {{
        'isTripMilesAir' => false,
        'tripMiles' => 0
      }}

      it 'is retrieved from Google' do  # rubocop:disable RSpec/MultipleExpectations
        expect(load.distance).to eq(123)
        expect(DistanceFromGoogle).to have_received(:call).with(origin: 'Passaic, NJ', destination: 'West Hartford, CT')
      end
    end
  end

  describe 'rate' do
    it 'is converted to cents' do
      expect(load.rate).to eq(60000)
    end
  end

  describe 'contact phone' do
    let(:load_data) {{ 'callback' => {'type' => 'Phone', 'phone' => '2125551212'} }}

    it 'is extracted' do
      expect(load.contact_phone).to eq('2125551212')
    end
  end

  describe 'contact email' do
    let(:load_data) {{ 'callback' => {'type' => 'Email', 'email' => 'punk@example.com'} }}

    it 'is extracted' do
      expect(load.contact_email).to eq('punk@example.com')
    end
  end

  it 'extracts notes' do
    expect(load.notes).to eq('Foo bar baz')
  end

  it 'extracts contact name' do
    expect(load.contact_name).to eq('Joe Bobkin')
  end

  it 'extracts broker company name' do
    expect(load.broker_company.to_s).to eq('Foo Logistics')
  end

  it 'creates load identifier model' do
    expect(load.load_identifier.identifier).to eq('ABC123')
  end

  it "doesn't create duplicates when called again" do
    expect { described_class.call(complete_load_data) }.not_to(change { Load.count })
  end

  # rubocop:disable Metrics/MethodLength
  def base_load_data
    {
      'matchId' => 'ABC123',
      'weight' => 4567,
      'origin' => {'city' => 'Passaic', 'state' => 'NJ'},
      'destination' => {'city' => 'West Hartford', 'state' => 'CT'},
      'rate' => 600,
      'pickupDate' => '2021-08-29T00:00:00.000Z',
      'isTripMilesAir' => false,
      'tripMiles' => 100,
      'comments' => ['Foo bar baz'],
      'combinedOfficeId' => '92187',
      'companyName' => 'Foo Logistics',
      'callback' => {'phone' => '2125551212', 'type' => 'Phone'},
      'contactName' => {'first' => 'Joe', 'last' => 'Bobkin'}
    }
  end
  # rubocop:enable Metrics/MethodLength
end
