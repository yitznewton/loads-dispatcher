class TqlRefresh < BaseRefresh
  REQUEST_HEADERS = {
    'Accept' => 'application/json',
    'Authorization' => 'Bearer',
    'Cache-Control' => 'no-cache',
    'Content-Type' => 'application/json',
    'tql-api-version' => '2.0'
  }.freeze

  URL = 'https://lmservicesext.tql.com/carrierdashboard.web/api/SearchLoads2/SearchAvailableLoadsByState/'.freeze

  # rubocop:disable Lint/MissingSuper
  def initialize(origin_date:)
    @origin_date = origin_date
  end
  # rubocop:enable Lint/MissingSuper

  attr_reader :origin_date

  def self.call(**kwargs)
    new(**kwargs).call
  end

  def response_exception_klass
    BadTqlResponse
  end

  def load_factory_klass
    TqlLoadFactory
  end

  def loads?(data)
    data.include?('PostedLoads')
  end

  def loads(data)
    data.fetch('PostedLoads')
  end

  def load_board
    LoadBoard.tql
  end

  def response_body(origin_city:, destination_city:)
    JSON.parse(Faraday.post(
      URL,
      request_payload(pickup_location: origin_city, dropoff_location: destination_city),
      REQUEST_HEADERS
    ).body)
  end

  # rubocop:todo Metrics/MethodLength
  def request_payload(pickup_location:, dropoff_location:)
    {
      CarrierID: nil,
      DestCity: dropoff_location.city,
      DestCityID: dropoff_location.tql_id,
      DestRadius: dropoff_location.radius,
      DestState: dropoff_location.state,
      IsActive: true,
      IsFavorite: 0,
      LoadDate: "#{origin_date.to_date}T04:00:00.000Z",
      OriginCity: pickup_location.city,
      OriginCityID: pickup_location.tql_id,
      OriginRadius: pickup_location.radius,
      OriginState: pickup_location.state,
      RowID: 0,
      SaveSearch: true,
      TrailerSizeId: 3,
      TrailerTypeId: 2,
      Weight: '17000'
    }.to_json
  end
  # rubocop:enable Metrics/MethodLength
end
