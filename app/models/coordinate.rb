class Coordinate < ApplicationRecord
  def self.for_place(place)
    present = find_by(name: place.to_s)
    return present if present

    coords = CoordinatesFromGoogle.call(place)
    return nil unless coords.present?

    create(coords.merge(name: place.to_s))
  end
end
