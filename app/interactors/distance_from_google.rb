class DistanceFromGoogle
  METERS_TO_MILES = 0.00062137
  URL = 'https://maps.googleapis.com/maps/api/distancematrix/json'.freeze

  # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
  def self.call(origin:, destination:)
    raise "Don't call me" if Rails.env.test?

    Rails.logger.debug(msg: 'Requesting distance from Google', origin: origin, destination: destination)

    params = {destinations: destination, origins: origin, units: 'imperial', key: ENV['GOOGLE_MAPS_API_KEY']}
    response_body = JSON.parse(Faraday.get(URL, params).body)
    raise BadGoogleResponse if response_body.include?('error_message')

    begin
      (response_body['rows'].first['elements'].first['distance']['value'] * METERS_TO_MILES).to_i
    rescue NoMethodError
      Rails.logger.info(msg: 'Could not get distance from Google', origin: origin, destination: destination)
      nil
    end
  end
  # rubocop:enable Metrics/AbcSize,Metrics/MethodLength
end
