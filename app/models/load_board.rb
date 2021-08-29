class LoadBoard < ApplicationRecord
  NAME_TQL = 'TQL'.freeze
  NAME_TRUCKERS_EDGE = 'Truckers Edge'.freeze

  has_many :load_identifiers, dependent: :delete_all
  has_many :loads, through: :load_identifiers

  def self.tql
    @tql ||= find_by!(name: NAME_TQL)
  end

  def self.truckers_edge
    @truckers_edge ||= find_by!(name: NAME_TRUCKERS_EDGE)
  end
end
