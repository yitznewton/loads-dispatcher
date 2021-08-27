class SearchLoads
  REQUEST_HEADERS = {
    'Accept' => 'application/json',
    'Authorization' => 'Bearer',
    'Cache-Control' => 'no-cache',
    'Content-Type' => 'application/json',
    'tql-api-version' => '2.0'
  }.freeze

  TIME_TEMPLATE = '%m/%d/%Y %H:%M:%S'.freeze

  def self.call(origin_location:, origin_date:)
    url = 'https://lmservicesext.tql.com/carrierdashboard.web/api/SearchLoads2/SearchAvailableLoadsByState/'
    City.all.map { |destination_city|
      cache_key = "tql/#{origin_date.to_s}/#{origin_location.id}/#{destination_city.id}"
      Rails.cache.fetch(cache_key, expires_in: 60.minutes) do
        response = Faraday.post(
          url,
          request_payload(pickup_location: origin_location, pickup_date: origin_date, dropoff_location: destination_city),
          REQUEST_HEADERS
        )
        JSON.parse(response.body).fetch('PostedLoads').map { |l| clean(l) }.select { |l| valid?(l) }
      end
    }.flatten
  end

  def self.clean(load)
    OpenStruct.new(
      pickup_date: Time.strptime(load.fetch('LoadDate'), TIME_TEMPLATE),
      dropoff_date: Time.strptime(load.fetch('DeliveryDate'), TIME_TEMPLATE),
      pickup_location: load.fetch('Origin').slice('City', 'StateCode').values.join(', '),
      dropoff_location: load.fetch('Destination').slice('City', 'StateCode').values.join(', '),
      weight: load.fetch('Weight'),
      distance: load.fetch('Miles'),
      notes: load.fetch('Notes'),
      original_data: load
    )
  end

  def self.valid?(load)
    binding.pry
    return false if load.weight == 0

    true
  end

  def self.request_payload(pickup_location:, pickup_date:, dropoff_location:)
    {
      CarrierID: nil,
      DestCity: dropoff_location.city,
      DestCityID: dropoff_location.tql_id,
      DestRadius: dropoff_location.radius,
      DestState: dropoff_location.state,
      IsActive: true,
      IsFavorite: 0,
      LoadDate: "#{pickup_date.to_s}T04:00:00.000Z",
      OriginCity: pickup_location.city,
      OriginCityID: pickup_location.tql_id,
      OriginRadius: pickup_location.radius,
      OriginState: pickup_location.state,
      RowID: 0,
      SaveSearch: true,
      TrailerSizeId: 3,
      TrailerTypeId: 2,
      Weight: "11000"
    }.to_json
  end
end