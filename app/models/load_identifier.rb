class LoadIdentifier < ApplicationRecord
  belongs_to :load_board
  has_one :load
end
