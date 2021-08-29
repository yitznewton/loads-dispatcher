class Place
  def initialize(place_data)
    @place_data = place_data
  end

  def city
    place_data['City'] || place_data['city']
  end

  def state
    place_data['StateCode'] || place_data['state']
  end

  def to_s
    "#{city}, #{state}"
  end

  private

  attr_reader :place_data
end
