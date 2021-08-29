class Place
  NYC_AND_LONG_ISLAND_COUNTIES = ['New York', 'Queens', 'Kings', 'Richmond', 'Bronx', 'Nassau', 'Suffolk']

  def initialize(place_data)
    @place_data = place_data
  end

  def city
    place_data['City'] || place_data['city']
  end

  def state
    place_data['StateCode'] || place_data['state']
  end

  def county
    place_data['county']
  end

  def nyc_or_long_island?
    state == 'NY' && NYC_AND_LONG_ISLAND_COUNTIES.include?(county)
  end

  def to_s
    "#{city}, #{state}"
  end

  private

  attr_reader :place_data
end
