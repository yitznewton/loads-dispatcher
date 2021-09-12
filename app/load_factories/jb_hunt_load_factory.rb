class JbHuntLoadFactory < BaseLoadFactory
  private

  def load_identifier
    @load_identifier ||= LoadIdentifier.find_or_create_by!(
      identifier: load_data['orderNumber'],
      load_board: LoadBoard.jb_hunt
    )
  end

  # rubocop:todo Metrics/AbcSize
  # rubocop:todo Metrics/MethodLength
  def parsed_attributes
    {
      weight: load_data['weight'].to_i,
      distance: distance,
      reference_number: load_data['orderNumber'],
      pickup_location: load_data['firstPickupLocation']['location'],
      pickup_date: load_data['firstPickupDate'].to_time,
      dropoff_date: load_data['lastDeliveryDate'].to_time,
      dropoff_location: load_data['lastDeliveryLocation']['location'],
      broker_company: broker_company,
      equipment_type: load_data['equipment']['type'].humanize
    }
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def broker_company
    @broker_company ||= BrokerCompanyIdentifier.find_by!(load_board: LoadBoard.jb_hunt).broker_company
  end

  def distance
    PlacesDistance.for_places(
      origin: Place.new(place_data(load_data, 'firstPickupLocation')),
      destination: Place.new(place_data(load_data, 'lastDeliveryLocation'))
    ).distance
  end

  def place_data(data, key)
    data.dig(key, 'location').tap { |p| p['city'] = p['city'].titleize }
  end
end
