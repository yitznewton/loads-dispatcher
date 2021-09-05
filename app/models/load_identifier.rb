class LoadIdentifier < ApplicationRecord
  belongs_to :load_board
  has_one :load, dependent: :nullify

  scope :active, -> { where(deleted_at: nil) }

  def destroy
    update(deleted_at: Time.current)
  end

  def undestroy
    update(deleted_at: nil)
  end

  def undestroy!
    update!(deleted_at: nil)
  end

  def deleted?
    deleted_at?
  end
end
