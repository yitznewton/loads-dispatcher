class TqlLoadFactory < BaseLoadFactory
  TIME_TEMPLATE = '%m/%d/%Y %H:%M:%S'.freeze

  private

  def load_identifier
    @load_identifier ||= LoadIdentifier.find_or_create_by!(
      identifier: load_data.fetch('PostIdReferenceNumber'),
      load_board: LoadBoard.tql
    )
  end

  # rubocop:todo Metrics/AbcSize
  # rubocop:todo Metrics/MethodLength
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
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

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
