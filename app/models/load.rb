class Load < ApplicationRecord
  MINIMUM_OFFERED_RATE = 100

  belongs_to :broker_company

  validates :weight, presence: true, numericality: { greater_than: 0 }
  validates :distance, presence: true, numericality: { greater_than: 0 }
  validates :pickup_date, presence: true

  validate :no_lowballs

  def rate_per_mile
    (rate + distance / 2) / distance if rate
  end

  def no_lowballs
    if rate_per_mile && rate_per_mile < MINIMUM_OFFERED_RATE
      errors.add(:no_lowballs, "Rate per mile needs to be higher than #{MINIMUM_OFFERED_RATE}")
    end
  end
end
