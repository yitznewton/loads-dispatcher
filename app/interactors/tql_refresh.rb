class TqlRefresh
  REQUEST_HEADERS = {
    'Accept' => 'application/json',
    'Authorization' => 'Bearer',
    'Cache-Control' => 'no-cache',
    'Content-Type' => 'application/json',
    'tql-api-version' => '2.0'
  }.freeze

  URL = 'https://lmservicesext.tql.com/carrierdashboard.web/api/SearchLoads2/SearchAvailableLoadsByState/'.freeze

  def self.call(origin_date:)
    Load.transaction do
      LoadBoard.tql.load_identifiers.delete_all

      City.routes.each do |(origin_city, destination_city)|
        data = response_body(destination_city, origin_city, origin_date)
        raise BadTqlResponse unless data.include?('PostedLoads')

        data.fetch('PostedLoads').each { |l| TqlLoadFactory.call(l) }
      end
    end
  end

  def self.response_body(destination_city, origin_city, origin_date)
    JSON.parse(Faraday.post(
      URL,
      request_payload(pickup_location: origin_city, pickup_date: origin_date, dropoff_location: destination_city),
      REQUEST_HEADERS
    ).body)
  end

  # rubocop:todo Metrics/MethodLength
  def self.request_payload(pickup_location:, pickup_date:, dropoff_location:)
    {
      CarrierID: nil,
      DestCity: dropoff_location.city,
      DestCityID: dropoff_location.tql_id,
      DestRadius: dropoff_location.radius,
      DestState: dropoff_location.state,
      IsActive: true,
      IsFavorite: 0,
      LoadDate: "#{pickup_date}T04:00:00.000Z",
      OriginCity: pickup_location.city,
      OriginCityID: pickup_location.tql_id,
      OriginRadius: pickup_location.radius,
      OriginState: pickup_location.state,
      RowID: 0,
      SaveSearch: true,
      TrailerSizeId: 3,
      TrailerTypeId: 2,
      Weight: '11000'
    }.to_json
  end
  # rubocop:enable Metrics/MethodLength
end
