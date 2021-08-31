class Load < ApplicationRecord
  MINIMUM_OFFERED_RATE = 100

  EXCLUDED_NOTES = {
    hazmat: 'hazmat',
    dry_van_only: 'dryvanonly',
    no_box_truck: 'noboxtruck',
    no_roll_door: 'norolldoor',
    dedicated_route: 'dedicationonthislane',
    drop_trailer: 'droptrailer'
  }.freeze

  belongs_to :broker_company
  belongs_to :load_identifier

  validates :weight, presence: true, numericality: { greater_than: 0 }
  validates :distance, presence: true, numericality: { greater_than: 0 }
  validates :pickup_date, presence: true

  validate :no_lowballs
  validate :no_excluded_notes
  validate :no_nyc_long_island

  scope :active, -> { joins(:load_identifier).where(dismissed_at: nil).merge(LoadIdentifier.active) }
  scope :shortlisted, -> { where.not(shortlisted_at: nil) }

  def dismiss!
    self.dismissed_at = Time.current
    save(validate: false)
  end

  def shortlisted?
    shortlisted_at?
  end

  def pickup_location
    Place.new(super)
  end

  def dropoff_location
    Place.new(super)
  end

  def rate_per_mile
    (rate + distance / 2) / distance if distance.nonzero? && rate
  end

  # rubocop:disable Style/GuardClause
  # rubocop:disable Style/IfUnlessModifier
  def no_lowballs
    if rate_per_mile && rate_per_mile < MINIMUM_OFFERED_RATE
      errors.add(:no_lowballs, "Rate per mile needs to be higher than #{MINIMUM_OFFERED_RATE}")
    end
  end

  def no_excluded_notes
    return unless notes.present?

    note_thing = notes.downcase.gsub(' ', '')

    EXCLUDED_NOTES.each do |key, excluded_text|
      if note_thing.include?(excluded_text)
        errors.add(key, 'Notes include excluded text')
      end
    end
  end

  def no_nyc_long_island
    places = [pickup_location, dropoff_location].compact
    return unless places.present?

    if places.any?(&:nyc_or_long_island?)
      errors.add(:no_nyc_long_island, 'Avoid NYC and Long Island')
    end
  end
  # rubocop:enable Style/GuardClause
  # rubocop:enable Style/IfUnlessModifier
end
