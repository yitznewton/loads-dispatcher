require 'rails_helper'

describe Load do
  subject(:load) { described_class.new(complete_attributes) }

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

  def base_attributes
    {
      pickup_date: Time.current,
      pickup_location: {city: 'Passaic', state: 'NJ', county: 'Passaic'},
      dropoff_location: {city: 'West Hartford', state: 'CT', county: 'Hartford'},
      weight: 5000,
      rate: 20000,
      distance: 100,
      broker_company: BrokerCompany.new(name: 'TQL'),
      load_identifier: LoadIdentifier.new(identifier: 'ABC123')
    }
  end
end
