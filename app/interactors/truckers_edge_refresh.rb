class TruckersEdgeRefresh < BaseRefresh
  BASE_REQUEST_HEADERS = {
    'Accept' => 'application/json',
    'Content-Type' => 'application/json',
    'dat-source-app' => 'te|2.0',
    'Origin' => 'https://truckersedge.dat.com/',
    'Referer' => 'https://truckersedge.dat.com/',
    'TE' => 'trailers',
    'User-Agent' => 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:91.0) Gecko/20100101 Firefox/91.0'
  }.freeze

  URL = 'https://freight.api.prod.dat.com/trucker/api/v2/freightMatching/search'.freeze

  # rubocop:disable Lint/MissingSuper
  def initialize(origin_date:, auth_token:)
    @origin_date = origin_date
    @auth_token = auth_token
  end
  # rubocop:enable Lint/MissingSuper

  attr_reader :origin_date, :auth_token

  def self.call(**kwargs)
    new(**kwargs).call
  end

  def response_exception_klass
    BadTruckersEdgeResponse
  end

  def load_factory_klass
    TruckersEdgeLoadFactory
  end

  def loads?(data)
    data.include?('matchDetails')
  end

  def loads(data)
    data.fetch('matchDetails')
  end

  def load_board
    LoadBoard.truckers_edge
  end

  def response_body(origin_city:, destination_city:)
    JSON.parse(Faraday.post(
      URL,
      request_payload(pickup_location: origin_city, dropoff_location: destination_city),
      BASE_REQUEST_HEADERS.merge('Authorization' => "Bearer #{auth_token}")
    ).body)
  end

  # rubocop:todo Metrics/MethodLength
  def request_payload(pickup_location:, dropoff_location:)
    {
      criteria: {
        origin: location_attributes(pickup_location),
        destination: location_attributes(dropoff_location),
        assetType: 'Shipment',
        startDate: origin_date.to_time.strftime('%Y-%m-%dT%H:%M:%SZ'),
        endDate: (origin_date.to_time + 3.days).strftime('%Y-%m-%dT%H:%M:%SZ'),
        doNotBook: false,
        equipmentTypes: %w[SB V VA VH VF],
        destinationDeadheadMiles: dropoff_location.radius.to_s,
        originDeadheadMiles: pickup_location.radius.to_s,
        isActiveSearch: false,
        ageLimitMinutes: 1440,
        sortOption: 'Age',
        sortDirection: 'Ascending',
        includeFulls: true,
        includeLtls: true,
        weightPounds: 17_000,
        minimumRelevanceThreshold: 0,
        hiddenMatchIds: []
      }
    }.to_json
  end
  # rubocop:enable Metrics/MethodLength

  def location_attributes(location)
    location.attributes.slice('city', 'state', 'latitude', 'longitude', 'county').merge(type: 'point')
  end
end

# DETAIL:
# commodity
# whenPickup
# whenDropOff
