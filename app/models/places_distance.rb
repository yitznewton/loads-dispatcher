class PlacesDistance < ApplicationRecord
  def self.for_places(origin:, destination:)
    return new(distance: 0) if origin == destination

    create_with(
      distance: DistanceFromGoogle.call(origin: origin.to_s, destination: destination.to_s)
    ).find_or_create_by(
      origin: origin.to_s,
      destination: destination.to_s
    )
  end
end
