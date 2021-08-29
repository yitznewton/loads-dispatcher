class PlacesDistance < ApplicationRecord
  def self.for_places(origin:, destination:)
    return new(distance: 0) if origin == destination

    create(
      origin: origin.to_s,
      destination: destination.to_s,
      distance: DistanceFromGoogle.call(origin: origin.to_s, destination: destination.to_s)
    )
  end
end
