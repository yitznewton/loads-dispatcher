require 'rails_helper'

describe 'Refresh' do
  before do
    City.create(
      city: 'Athens',
      state: 'GA',
      radius: 150,
      county: 'Foo',
      latitude: 45.67,
      longitude: -12.34
    )
  end

  let(:described_class) {
    Class.new(BaseRefresh) do
      def initialize(data)
        @data = data
      end

      def response_body(**_)
        @data
      end

      def loads?(_)
        true
      end

      def loads(load_data)
        load_data
      end

      def load_board
        LoadBoard.first
      end

      def response_exception_klass
        StandardError
      end

      def load_factory_klass
        Class.new do
          def self.call(data)
            Load.create!(data)
          end
        end
      end
    end
  }

  let!(:load_board) { LoadBoard.create!(name: 'TQL') }
  let!(:broker_company) { BrokerCompany.create!(name: 'Foo Brokers') }
  let!(:load_identifier) { LoadIdentifier.create!(identifier: 'ABC123', load_board: load_board) }

  let(:load_data) {{
    weight: 8_000,
    distance: 150,
    pickup_date: Time.current,
    pickup_location: {city: 'Athens', state: 'GA'},
    dropoff_location: {city: 'Atlanta', state: 'GA'},
    broker_company: broker_company,
    load_identifier: load_identifier
  }}

  it 'adds new loads' do
    expect { described_class.new([load_data]).call }.to(change { Load.count }.by(1))
  end

  # rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
  it 'deletes missing identifiers from only the same load board' do
    other_load_board = LoadBoard.create!(name: 'something else')
    ident_from_same_board = LoadIdentifier.create!(identifier: 'XYZ987', load_board: load_board)
    ident_from_other_board = LoadIdentifier.create!(identifier: 'MNO546', load_board: other_load_board)
    Load.create!(load_data.merge(load_identifier: ident_from_same_board))
    Load.create!(load_data.merge(load_identifier: ident_from_other_board))

    described_class.new([load_data]).call

    expect(ident_from_same_board.reload).to be_deleted
    expect(ident_from_other_board.reload).not_to be_deleted
  end
  # rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations
end
