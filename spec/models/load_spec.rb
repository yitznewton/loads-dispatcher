require 'rails_helper'

describe Load do
  subject(:load) { described_class.new(complete_attributes) }

  let!(:broker_company) { BrokerCompany.create!(name: 'TQL') }
  let!(:load_board) { LoadBoard.create!(name: 'TQL') }
  let!(:load_identifier) { LoadIdentifier.create!(identifier: 'ABC123', load_board: load_board) }

  let(:pickup_date) { Time.current }
  let(:complete_attributes) { base_attributes.merge(attributes) }
  let(:attributes) {{}}

  describe 'validation' do
    context 'with a lowball rate' do
      let(:attributes) {{ rate: 9000 }}

      specify do
        expect(load).not_to be_valid
      end
    end

    context 'with a box truck exclusion' do
      let(:attributes) {{ notes: 'No box trucks!!' }}

      specify do
        expect(load).not_to be_valid
      end
    end

    context 'with an NYC/Long Island pickup' do
      let(:attributes) {{ pickup_location: {city: 'A', state: 'NY', county: 'Queens'} }}

      specify do
        expect(load).not_to be_valid
      end
    end

    context 'with an NYC/Long Island dropoff' do
      let(:attributes) {{ dropoff_location: {city: 'A', state: 'NY', county: 'Suffolk'} }}

      specify do
        expect(load).not_to be_valid
      end
    end

    context 'when specifying no roll doors' do
      let(:attributes) {{ notes: 'No roll doors!!' }}

      specify do
        expect(load).not_to be_valid
      end
    end
  end

  it 'calculates age' do
    created_at = '2021-08-31T12:00:00Z'.to_time
    current_time = '2021-08-31T13:30:00Z'.to_time
    load = described_class.new(created_at: created_at)

    expect(load.hours_old(current_time)).to be_within(0.001).of(1.5)
  end

  describe 'versioning' do
    before do
      load.save!
    end

    context 'when updating a watched attribute' do
      let(:updated_attributes) {{ weight: 7000 }}

      it 'creates a new version' do
        expect { load.update!(base_attributes.merge(updated_attributes)) }.to(change { load.versions.size }.by(1) )
      end
    end

    context 'when updating an unwatched attribute' do
      let(:updated_attributes) {{ shortlisted_at: Time.current }}

      it 'does not create a new version' do
        expect { load.update!(base_attributes.merge(updated_attributes)) }.not_to(change { load.versions.size })
      end
    end
  end

  def base_attributes
    {
      pickup_date: pickup_date,
      pickup_location: {city: 'Passaic', state: 'NJ', county: 'Passaic'},
      dropoff_location: {city: 'West Hartford', state: 'CT', county: 'Hartford'},
      weight: 5000,
      rate: 20000,
      distance: 100,
      broker_company: broker_company,
      load_identifier: load_identifier
    }
  end
end
