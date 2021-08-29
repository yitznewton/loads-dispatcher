class TqlRefresh
  REQUEST_HEADERS = {
    'Accept' => 'application/json',
    'Authorization' => 'Bearer',
    'Cache-Control' => 'no-cache',
    'Content-Type' => 'application/json',
    'tql-api-version' => '2.0'
  }.freeze

  def self.call(origin_date:)
    url = 'https://lmservicesext.tql.com/carrierdashboard.web/api/SearchLoads2/SearchAvailableLoadsByState/'

    Load.transaction do
      LoadBoard.tql.load_identifiers.delete_all

      City.routes.each do |(origin_city, destination_city)|
        cache_key = "tql/#{origin_date.to_s}/#{origin_city.id}/#{destination_city.id}"

        data = begin
                 Rails.cache.fetch(cache_key, expires_in: 600.minutes) do
                   response = Faraday.post(
                     url,
                     request_payload(pickup_location: origin_city, pickup_date: origin_date, dropoff_location: destination_city),
                     REQUEST_HEADERS
                   )
                   JSON.parse(response.body).tap do |data|
                     raise BadTqlResponse unless data.include?('PostedLoads')
                   end
                 end
               rescue BadTqlResponse
                 # don't cache it
               end

        data.fetch('PostedLoads').each { |l| TqlLoadFactory.call(l) }
      end
    end
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
