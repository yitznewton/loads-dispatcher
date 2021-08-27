class Load < ApplicationRecord
  MINIMUM_OFFERED_RATE = 100

  validates :weight, presence: true, numericality: { greater_than: 0 }
  validates :distance, presence: true, numericality: { greater_than: 0 }
  validates :reference_number, presence: true

  validate :no_lowballs

  def no_lowballs
    if rate && rate > 0 && rate / distance < MINIMUM_OFFERED_RATE
      errors.add(:no_lowballs, "Rate needs to be higher than #{MINIMUM_OFFERED_RATE}")
    end
  end
end
