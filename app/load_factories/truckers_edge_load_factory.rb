class TruckersEdgeLoadFactory < BaseLoadFactory
  CALLBACK_TYPE_PHONE = 'Phone'.freeze
  CALLBACK_TYPE_EMAIL = 'Email'.freeze

  private

  def load_identifier
    @load_identifier ||= LoadIdentifier.find_or_create_by!(
      identifier: load_data.fetch('matchId'),
      load_board: LoadBoard.truckers_edge
    )
  end

  # rubocop:todo Metrics/AbcSize
  # rubocop:todo Metrics/CyclomaticComplexity
  # rubocop:todo Metrics/MethodLength
  def parsed_attributes
    {
      weight: load_data['weight'],
      length: load_data['length'],
      distance: distance,
      rate: load_data['rate']&.*(100)&.nonzero?,
      contact_name: load_data['contactName']&.slice('first', 'last')&.values&.compact&.join(' '),
      contact_phone: phone(load_data['callback']),
      contact_email: email(load_data['callback']),
      reference_number: load_data['postersReferenceId'],
      pickup_location: load_data['origin'],
      pickup_date: load_data['pickupDate'].to_time,
      dropoff_location: load_data['destination'],
      broker_company: broker_company_identifier.broker_company,
      notes: load_data['comments']&.join('. '),
      raw: load_data
    }
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength

  def broker_company_identifier
    BrokerCompanyIdentifier
      .create_with(broker_company: BrokerCompany.new(name: load_data.fetch('companyName')))
      .find_or_create_by(identifier: load_data.fetch('combinedOfficeId'), load_board: LoadBoard.truckers_edge)
  end

  def phone(callback)
    callback.fetch('phone') if callback.fetch('type') == CALLBACK_TYPE_PHONE
  end

  def email(callback)
    callback.fetch('email') if callback.fetch('type') == CALLBACK_TYPE_EMAIL
  end

  def distance
    return our_distance if load_data.fetch('isTripMilesAir')

    load_data.fetch('tripMiles').nonzero? || our_distance
  end

  def our_distance
    PlacesDistance.for_places(
      origin: Place.new(load_data.fetch('origin')),
      destination: Place.new(load_data.fetch('destination'))
    ).distance
  end
end
