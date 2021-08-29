class LoadBoard < ApplicationRecord
  NAME_TRUCKERS_EDGE = 'Truckers Edge'.freeze

  def self.truckers_edge
    @truckers_edge ||= find_by(name: NAME_TRUCKERS_EDGE)
  end
end
