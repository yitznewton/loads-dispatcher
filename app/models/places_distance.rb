class PlacesDistance < ApplicationRecord
  def self.for_places(origin:, destination:)
    return new(distance: 0) if origin == destination

    attributes = {
      origin: origin.to_s,
      destination: destination.to_s
    }

    present = find_by(attributes)
    return present if present

    distance = DistanceFromGoogle.call(origin: origin.to_google, destination: destination.to_google)

    create(attributes.merge(distance: distance))
  end
end
