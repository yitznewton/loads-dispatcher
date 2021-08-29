class TruckersEdgeSearchLoads
  BASE_REQUEST_HEADERS = {
    'Accept' => 'application/json',
    'Content-Type' => 'application/json',
    'dat-source-app' => 'te|2.0',
    'Origin' => 'https://truckersedge.dat.com/',
    'Referer' => 'https://truckersedge.dat.com/',
    'TE' => 'trailers',
    'User-Agent' => 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:91.0) Gecko/20100101 Firefox/91.0'
  }.freeze

  # TIME_TEMPLATE = '%m/%d/%Y %H:%M:%S'.freeze
  CALLBACK_TYPE_PHONE = 'Phone'.freeze
  CALLBACK_TYPE_EMAIL = 'Email'.freeze
  METERS_TO_MILES = 0.00062137

  def self.call(origin_location:, origin_date:, auth_token:)
    url = 'https://freight.api.prod.dat.com/trucker/api/v2/freightMatching/search'
    City.all.map { |destination_city|
      cache_key = "truckers_edge/#{origin_date.to_s}/#{origin_location.id}/#{destination_city.id}"

      data = Rails.cache.fetch(cache_key, expires_in: 600.minutes) do
        response = Faraday.post(
          url,
          request_payload(pickup_location: origin_location, pickup_date: origin_date, dropoff_location: destination_city),
          BASE_REQUEST_HEADERS.merge('Authorization' => "Bearer #{auth_token}")
        )
        JSON.parse(response.body)
      end

      data.fetch('matchDetails').map { |l| create(l) }.compact
    }.flatten
  end

  def self.create(load)
    load = Load.new(
      weight: load['weight'],
      length: load['length'],
      distance: distance(load),
      rate: load['rate']&.*(100)&.nonzero?,
      contact_name: load['contactName']&.slice('first', 'last')&.values&.compact&.join(' '),
      contact_phone: phone(load['callback']),
      contact_email: email(load['callback']),
      reference_number: load['postersReferenceId'],
      pickup_location: load['origin'],
      pickup_date: load['pickupDate'].to_time,
      dropoff_location: load['destination'],
      broker_company: load['companyName'],
      notes: load['comments']&.join('. '),
      other: load
    )

    load if load.save
  end

  def self.phone(callback)
    callback.fetch('phone') if callback.fetch('type') == CALLBACK_TYPE_PHONE
  end

  def self.email(callback)
    callback.fetch('email') if callback.fetch('type') == CALLBACK_TYPE_EMAIL
  end

  def self.distance(load)
    if load.fetch('isTripMilesAir')
      return distance_from_google!(load.fetch('origin'), load.fetch('destination'))
    end

    load.fetch('tripMiles').nonzero? || distance_from_google!(load.fetch('origin'), load.fetch('destination'))
  end

  def self.distance_from_google!(origin, destination)
    origin = origin.slice('city', 'state').values.join(', ')
    destination = destination.slice('city', 'state').values.join(', ')
    payload = Rails.cache.fetch("#{origin}/#{destination}") do
      url = 'https://maps.googleapis.com/maps/api/distancematrix/json'
      params = {destinations: destination, origins: origin, units: 'imperial', key: ENV['GOOGLE_MAPS_API_KEY']}
      response = Faraday.get(url, params)
      JSON.parse(response.body)
    end

    (payload['rows'].first['elements'].first['distance']['value'] * METERS_TO_MILES).to_i
  end

  # def self.valid?(load)
  #   return false if load.weight == 0
  #
  #   true
  # end

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
