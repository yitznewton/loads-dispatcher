class DistanceFromGoogle
  METERS_TO_MILES = 0.00062137
  URL = 'https://maps.googleapis.com/maps/api/distancematrix/json'.freeze

  # rubocop:disable Metrics/AbcSize
  def self.call(origin:, destination:)
    raise "Don't call me" if Rails.env.test?

    Rails.logger.debug(msg: 'Requesting distance from Google', origin: origin, destination: destination)

    params = {destinations: destination, origins: origin, units: 'imperial', key: ENV['GOOGLE_MAPS_API_KEY']}
    response_body = JSON.parse(Faraday.get(URL, params).body)
    raise BadGoogleResponse if response_body.include?('error_message')

    (response_body['rows'].first['elements'].first['distance']['value'] * METERS_TO_MILES).to_i
  end
  # rubocop:enable Metrics/AbcSize
end
