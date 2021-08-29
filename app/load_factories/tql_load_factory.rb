class TqlLoadFactory
  TIME_TEMPLATE = '%m/%d/%Y %H:%M:%S'.freeze

  def initialize(load_data)
    @load_data = load_data
  end

  def self.call(load_data)
    new(load_data).call
  end

  attr_reader :load_data

  def call
    Load.transaction do
      load = Load.find_by(load_identifier: load_identifier)

      if load
        load.update(parsed_attributes)
        load.destroy unless load.valid?
        next
      end

      Load.create(parsed_attributes.merge(load_identifier: load_identifier))
    end
  end

  private

  def load_identifier
    @load_identifier ||= LoadIdentifier.find_or_create_by!(
      identifier: load_data.fetch('PostIdReferenceNumber'),
      load_board: LoadBoard.tql
    )

  end

  def parsed_attributes
    {
      weight: load_data.fetch('Weight'),
      distance: distance,
      reference_number: load_data.fetch('PostIdReferenceNumber'),
      pickup_location: load_data.fetch('Origin'),
      pickup_date: Time.strptime(load_data.fetch('LoadDate'), TIME_TEMPLATE),
      dropoff_location: load_data.fetch('Destination'),
      dropoff_date: Time.strptime(load_data.fetch('DeliveryDate'), TIME_TEMPLATE),
      commodity: load_data['CommoditySummary'],
      notes: load_data.fetch('Notes'),
      broker_company: broker_company,
      raw: load_data
    }
  end

  def broker_company
    @broker_company ||= BrokerCompanyIdentifier.find_by!(load_board: LoadBoard.tql).broker_company
  end

  def distance
    load_data.fetch('Miles').nonzero? || our_distance
  end

  def our_distance
    PlacesDistance.for_places(
      origin: Place.new(load_data.fetch('Origin')),
      destination: Place.new(load_data.fetch('Destination'))
    ).distance
  end
end
