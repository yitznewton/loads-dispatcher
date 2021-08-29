class TruckersEdgeLoadFactory
  CALLBACK_TYPE_PHONE = 'Phone'.freeze
  CALLBACK_TYPE_EMAIL = 'Email'.freeze

  def initialize(load_data)
    @load_data = load_data
  end

  def self.call(load_data)
    new(load_data).call
  end

  attr_reader :load_data

  def call
    load_identifier = LoadIdentifier.find_by(identifier: load_data.fetch('matchId'), load_board: LoadBoard.truckers_edge)
    return if load_identifier

    Load.transaction do
      load = Load.new(
        weight: load_data['weight'],
        length: load_data['length'],
        distance: distance(load_data),
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
      )

      next unless load.save

      LoadIdentifier.create(identifier: load_data.fetch('matchId'), load: load, load_board: LoadBoard.truckers_edge)
    end
  end

  private

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
    return distance_from_google if load_data.fetch('isTripMilesAir')

    load_data.fetch('tripMiles').nonzero? || distance_from_google
  end

  def distance_from_google
    DistanceFromGoogle.call(
      origin: load_data.fetch('origin').slice('city', 'state').values.join(', '),
      destination: load_data.fetch('destination').slice('city', 'state').values.join(', ')
    )
  end
end
