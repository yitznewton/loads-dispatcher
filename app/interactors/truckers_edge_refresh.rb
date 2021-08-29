class TruckersEdgeRefresh
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

  def self.call(origin_date:, auth_token:)
    Load.transaction do
      LoadBoard.truckers_edge.load_identifiers.delete_all

      City.routes.each do |(origin_city, destination_city)|
        data = response_body(auth_token, destination_city, origin_city, origin_date)
        raise BadTruckersEdgeResponse unless data.include?('matchDetails')

        data.fetch('matchDetails').each { |l| TruckersEdgeLoadFactory.call(l) }
      end
    end
  end

  def self.response_body(auth_token, destination_city, origin_city, origin_date)
    JSON.parse(Faraday.post(
      URL,
      request_payload(pickup_location: origin_city, pickup_date: origin_date, dropoff_location: destination_city),
      BASE_REQUEST_HEADERS.merge('Authorization' => "Bearer #{auth_token}")
    ).body)
  end

  # rubocop:todo Metrics/MethodLength
  def self.request_payload(pickup_location:, pickup_date:, dropoff_location:)
    {
      criteria: {
        origin: location_attributes(pickup_location),
        destination: location_attributes(dropoff_location),
        assetType: 'Shipment',
        startDate: pickup_date.to_time.strftime('%Y-%m-%dT%H:%M:%SZ'),
        endDate: (pickup_date.to_time + 3.days).strftime('%Y-%m-%dT%H:%M:%SZ'),
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
        weightPounds: 11_000,
        minimumRelevanceThreshold: 0,
        hiddenMatchIds: []
      }
    }.to_json
  end
  # rubocop:enable Metrics/MethodLength

  def self.location_attributes(location)
    location.attributes.slice('city', 'state', 'latitude', 'longitude', 'county').merge(type: 'point')
  end
end

# DETAIL:
# commodity
# whenPickup
# whenDropOff
