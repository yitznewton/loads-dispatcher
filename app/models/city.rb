class City < ApplicationRecord
  def self.routes
    cities = all
    cities.to_a.permutation(2) + cities.map { |c| [c, c] }
  end

  def to_s
    "#{city}, #{state}"
  end
end
