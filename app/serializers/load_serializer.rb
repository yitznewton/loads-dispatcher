class LoadSerializer < ActiveModel::Serializer
  include LoadsHelper

  attributes :id, :pickup_date, :dropoff_date, :weight, :distance, :rate, :rate_per_mile, :equipment_type_code

  attribute(:pickup_location) { PlaceSerializer.new(object.pickup_location) }
  attribute(:dropoff_location) { PlaceSerializer.new(object.dropoff_location) }
  attribute(:rate) { currency(object.rate, show_cents: false) }
  attribute(:rate_per_mile) { currency(object.rate_per_mile) }
  attribute(:shortlisted) { object.shortlisted_at? }
end
