class TruckersEdgeLoadFactory < BaseLoadFactory
  CALLBACK_TYPE_PHONE = 'Phone'.freeze
  CALLBACK_TYPE_EMAIL = 'Email'.freeze

  private

  def load_identifier
    @load_identifier ||= LoadIdentifier.find_or_create_by!(
      identifier: load_identifier_string,
      load_board: LoadBoard.truckers_edge
    )
  end

  # rubocop:disable Metrics/AbcSize
  def load_identifier_string
    if load_data['postersReferenceId'].present?
      return "company/#{broker_company_identifier.id}/ref/#{load_data.fetch('postersReferenceId')}"
    end

    [
      'company',     broker_company_identifier.id,
      'pickup_time', load_data['pickupDate'].to_date,
      'origin',      load_data['origin'],
      'destination', load_data['destination'],
      'weight',      load_data['weight']
    ].join('/')
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:todo Metrics/AbcSize
  # rubocop:todo Metrics/CyclomaticComplexity
  # rubocop:todo Metrics/MethodLength
  # rubocop:todo Metrics/PerceivedComplexity
  def parsed_attributes
    {
      weight: load_data['weight'],
      length: load_data['length'],
      distance: distance,
      rate: load_data['rate']&.*(100)&.nonzero?&.to_i,
      contact_name: load_data['contactName']&.slice('first', 'last')&.values&.compact&.join(' '),
      contact_phone: phone(load_data['callback']),
      contact_email: email(load_data['callback']),
      reference_number: load_data['postersReferenceId'],
      pickup_location: load_data['origin'],
      pickup_date: load_data['pickupDate'].to_time,
      dropoff_location: load_data['destination'],
      broker_company: broker_company_identifier.broker_company,
      notes: load_data['comments']&.join('. '),
      equipment_type: load_data['equipmentType'],
      equipment_type_code: load_data['equipmentTypeCode']
    }
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity

  # rubocop:disable Layout/MultilineMethodCallIndentation
  def broker_company_identifier
    @broker_company_identifier ||= BrokerCompanyIdentifier
      .create_with(broker_company: BrokerCompany.new(name: load_data.fetch('companyName')))
      .find_or_create_by(identifier: load_data.fetch('combinedOfficeId'), load_board: LoadBoard.truckers_edge)
  end
  # rubocop:enable Layout/MultilineMethodCallIndentation

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
