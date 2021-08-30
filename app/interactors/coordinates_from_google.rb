class CoordinatesFromGoogle
  URL = 'https://maps.googleapis.com/maps/api/geocode/json'.freeze
  STATUS_OK = 'OK'.freeze

  def self.call(place)
    raise "Don't call me" if Rails.env.test?

    Rails.logger.debug(msg: 'Requesting geocoding from Google', place: place)

    params = {address: place, key: ENV['GOOGLE_MAPS_API_KEY']}
    response_body = JSON.parse(Faraday.get(URL, params).body)
    raise BadGoogleResponse(response_body['error_message']) if response_body.include?('error_message')
    return nil unless response_body['results'].present?

    location = response_body['results'].first.dig('geometry', 'location')
    { latitude: location['lat'], longitude: location['lng'] }
  end
end
