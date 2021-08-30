class LoadSerializer < ActiveModel::Serializer
  attributes :id, :pickup_date, :dropoff_date, :weight, :rate, :rate_per_mile

  attribute(:pickup_location) { PlaceSerializer.new(object.pickup_location) }
  attribute(:dropoff_location) { PlaceSerializer.new(object.dropoff_location) }
end
