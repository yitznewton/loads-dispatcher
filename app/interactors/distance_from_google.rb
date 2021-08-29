class DistanceFromGoogle
  METERS_TO_MILES = 0.00062137

  def self.call(origin:, destination:)
    Rails.logger.debug('Requesting location from Google', origin: origin, destination: destination)

    payload = Rails.cache.fetch("#{origin}/#{destination}") do
      url = 'https://maps.googleapis.com/maps/api/distancematrix/json'
      params = {destinations: destination, origins: origin, units: 'imperial', key: ENV['GOOGLE_MAPS_API_KEY']}
      response = Faraday.get(url, params)
      JSON.parse(response.body)
    end

    (payload['rows'].first['elements'].first['distance']['value'] * METERS_TO_MILES).to_i
  end
end
