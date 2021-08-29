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
    load_identifier = LoadIdentifier.find_by(identifier: load_data.fetch('PostIdReferenceNumber'), load_board: LoadBoard.tql)
    return if load_identifier

    Load.transaction do
      load = Load.new(
        weight: load_data.fetch('Weight'),
        distance: distance,
        reference_number: load_data.fetch('PostIdReferenceNumber'),
        pickup_location: load_data.fetch('Origin'),
        pickup_date: Time.strptime(load_data.fetch('LoadDate'), TIME_TEMPLATE),
        dropoff_location: load_data.fetch('Destination'),
        dropoff_date: Time.strptime(load_data.fetch('DeliveryDate'), TIME_TEMPLATE),
        notes: load_data.fetch('Notes'),
        broker_company: BrokerCompany.tql,
        raw: load_data
      )

      next unless load.save

      LoadIdentifier.create(identifier: load_data.fetch('PostIdReferenceNumber'), load: load, load_board: LoadBoard.tql)
    end
  end

  private

  def broker_company_identifier
    BrokerCompanyIdentifier
      .create_with(broker_company: BrokerCompany.new(name: load_data.fetch('companyName')))
      .find_or_create_by(identifier: load_data.fetch('combinedOfficeId'), load_board: LoadBoard.truckers_edge)
  end

  def distance
    load_data.fetch('Miles').nonzero? || distance_from_google
  end

  def distance_from_google
    DistanceFromGoogle.call(
      origin: load_data.fetch('Origin').slice('City', 'StateCode').values.join(', '),
      destination: load_data.fetch('Destination').slice('City', 'StateCode').values.join(', ')
    )
  end
end
