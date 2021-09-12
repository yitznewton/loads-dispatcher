class Place
  include ActiveModel::Serialization

  NYC_AND_LONG_ISLAND_COUNTIES = ['New York', 'Queens', 'Kings', 'Richmond', 'Bronx', 'Nassau', 'Suffolk'].freeze

  def initialize(place_data)
    @place_data = place_data.with_indifferent_access
  end

  def city
    place_data['City'] || place_data['city']
  end

  def state
    place_data['StateCode'] || place_data['state']
  end

  def latitude
    place_data['latitude'] || place_data['Latitude']
  end

  def longitude
    place_data['longitude'] || place_data['Longitude']
  end

  def county
    place_data['county']
  end

  def nyc_or_long_island?
    state == 'NY' && NYC_AND_LONG_ISLAND_COUNTIES.include?(county)
  end

  def ==(other)
    to_s == other.to_s
  end

  def to_s
    "#{city}, #{state}"
  end

  def to_google
    latitude && longitude ? "#{latitude},#{longitude}" : to_s
  end

  private

  attr_reader :place_data
end
