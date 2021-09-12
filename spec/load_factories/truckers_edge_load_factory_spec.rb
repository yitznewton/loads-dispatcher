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

  # rubocop:disable RSpec/ExampleLength
  describe 'unique identification' do
    context 'when a reference number is present' do
      let(:load_data) {{
        'matchId' => 'a',
        'postersReferenceId' => 'ABC123',
        'combinedOfficeId' => '92817'
      }}

      it 'uses company identifier and reference number' do
        second_load_data = complete_load_data.merge(
          'matchId' => 'b'
        )

        third_load_data = complete_load_data.merge(
          'matchId' => 'c',
          'combinedOfficeId' => '28179'
        )

        expect { described_class.call(second_load_data) }.not_to(change { Load.count })
        expect { described_class.call(third_load_data) }.to(change { Load.count }.by(1))
      end
    end

    context 'when no reference number is present' do
      let(:load_data) {{
        'matchId' => 'a',
        'postersReferenceId' => nil,
        'origin' => {'city' => 'Passaic', 'state' => 'NJ'},
        'destination' => {'city' => 'West Hartford', 'state' => 'CT'},
        'pickupDate' => '2021-08-29T00:00:00.000Z',
        'weight' => 600,
        'combinedOfficeId' => '92817'
      }}

      it 'uses company identifier, pickup time, pickup and dropoff locations, and weight' do
        second_load_data = complete_load_data.merge(
          'matchId' => 'b'
        )

        differentiating_load_data = [
          complete_load_data.merge(
            'matchId' => 'c',
            'combinedOfficeId' => '28179'
          ),
          complete_load_data.merge(
            'matchId' => 'd',
            'pickupDate' => '2021-08-29T12:00:00.000Z'
          ),
          complete_load_data.merge(
            'matchId' => 'e',
            'origin' => {'city' => 'Hackensack', 'state' => 'NJ'}
          ),
          complete_load_data.merge(
            'matchId' => 'f',
            'destination' => {'city' => 'Bloomfield', 'state' => 'CT'}
          ),
          complete_load_data.merge(
            'matchId' => 'g',
            'weight' => 800
          )
        ]

        expect { described_class.call(second_load_data) }.not_to(change { Load.count })

        differentiating_load_data.each do |data|
          expect { described_class.call(data) }.to(change { Load.count }.by(1), "#{data} expected to add a load")
        end
      end
    end
  end
  # rubocop:enable RSpec/ExampleLength

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

      it 'is retrieved from Google' do
        expect(load.distance).to eq(123)
        expect(DistanceFromGoogle).to have_received(:call).with(origin: 'Passaic, NJ', destination: 'West Hartford, CT')
      end
    end
  end

  describe 'rate' do
    it 'is converted to cents' do
      expect(load.rate).to eq(60000)
    end

    context 'when it is a miserable float' do
      let(:load_data) {{ 'rate' => 123.456789 }}

      it 'truncates' do
        expect { described_class.call(complete_load_data) }.not_to(change { Rate.count })
      end
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

  it 'extracts contact name' do
    expect(load.contact_name).to eq('Joe Bobkin')
  end

  it 'extracts broker company name' do
    expect(load.broker_company.to_s).to eq('Foo Logistics')
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
      'contactName' => {'first' => 'Joe', 'last' => 'Bobkin'},
      'postersReferenceId' => 'ABC123'
    }
  end
  # rubocop:enable Metrics/MethodLength
end
