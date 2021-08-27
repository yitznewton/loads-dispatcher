class City < ApplicationRecord
  def to_s
    "#{city}, #{state}"
  end
end
