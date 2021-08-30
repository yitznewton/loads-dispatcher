class LoadIdentifier < ApplicationRecord
  belongs_to :load_board
  has_one :load

  scope :active, -> { where(deleted_at: nil) }
end
