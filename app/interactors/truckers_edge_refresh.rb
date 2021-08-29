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

  def self.call(origin_location:, origin_date:, auth_token:)
    url = 'https://freight.api.prod.dat.com/trucker/api/v2/freightMatching/search'

    Load.transaction do
      LoadBoard.truckers_edge.loads.delete_all

      City.all.each do |destination_city|
        cache_key = "truckers_edge/#{origin_date.to_s}/#{origin_location.id}/#{destination_city.id}"

        data = begin
                 Rails.cache.fetch(cache_key, expires_in: 600.minutes) do
                   response = Faraday.post(
                     url,
                     request_payload(pickup_location: origin_location, pickup_date: origin_date, dropoff_location: destination_city),
                     BASE_REQUEST_HEADERS.merge('Authorization' => "Bearer #{auth_token}")
                   )
                   JSON.parse(response.body).tap do |data|
                     raise BadTruckersEdgeResponse unless data.include?('matchDetails')
                   end
                 end
               rescue BadTruckersEdgeResponse
                 # don't cache it
               end

        data.fetch('matchDetails').each { |l| TruckersEdgeLoadFactory.call(l) }
      end
    end
  end

  def self.request_payload(pickup_location:, pickup_date:, dropoff_location:)
    {
      criteria: {
        origin: pickup_location.attributes.slice('city', 'state', 'latitude', 'longitude', 'county').merge(type: 'point'),
        destination: dropoff_location.attributes.slice('city', 'state', 'latitude', 'longitude', 'county').merge(type: 'point'),
        assetType: "Shipment",
        startDate: pickup_date.to_time.strftime('%Y-%m-%dT%H:%M:%SZ'),
        endDate: (pickup_date.to_time + 3.days).strftime('%Y-%m-%dT%H:%M:%SZ'),
        doNotBook: false,
        equipmentTypes: %w[SB V VA VH VF],
        destinationDeadheadMiles: dropoff_location.radius.to_s,
        originDeadheadMiles: pickup_location.radius.to_s,
        isActiveSearch: false,
        ageLimitMinutes: 1440,
        sortOption: "Age",
        sortDirection: "Ascending",
        includeFulls: true,
        includeLtls: true,
        weightPounds: 11000,
        minimumRelevanceThreshold: 0,
        hiddenMatchIds: []
      }
    }.to_json
  end
end


# DETAIL:
# commodity
# whenPickup
# whenDropOff

# SEARCH:
# searchId and totalMatchCount (top level; the rest are under matchDetails)
# matchId
# weight
# length
# tripMiles
# isTripMilesAir
# rate
# callback: phone, type
# contactName: first, last
# postersReferenceId
# availability: earliest, latest
# origin: city, state, latitude, longitude, county, type: minimalPoint
# destination: "
# companyName
# equipmentType
# equipmentTypeCode
# pickupDate
