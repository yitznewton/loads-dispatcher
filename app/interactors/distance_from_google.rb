class DistanceFromGoogle
  METERS_TO_MILES = 0.00062137

  def self.call(origin:, destination:)
    raise "Don't call me" if Rails.env.test?

    Rails.logger.debug(msg: 'Requesting location from Google', origin: origin, destination: destination)

    url = 'https://maps.googleapis.com/maps/api/distancematrix/json'
    params = {destinations: destination, origins: origin, units: 'imperial', key: ENV['GOOGLE_MAPS_API_KEY']}
    response = Faraday.get(url, params)
    payload = JSON.parse(response.body)
    raise BadGoogleDistanceResponse if payload.include?('error_message')

    (payload['rows'].first['elements'].first['distance']['value'] * METERS_TO_MILES).to_i
  end
end
