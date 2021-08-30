class PlaceSerializer < ActiveModel::Serializer
  attribute(:lat) { object.latitude }
  attribute(:lng) { object.longitude }
  attribute(:readable) { object.to_s }
end
