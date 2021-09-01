class LoadIdentifier < ApplicationRecord
  belongs_to :load_board
  has_one :load, dependent: :nullify

  scope :active, -> { where(deleted_at: nil) }

  def destroy
    update(deleted_at: Time.current)
  end
end
