class BrokerCompany < ApplicationRecord
  has_many :broker_company_identifiers
  has_many :loads

  NAME_TQL = 'TQL'.freeze

  def self.tql
    @tql ||= find_by!(name: NAME_TQL)
  end

  def to_s
    name
  end
end
