class BrokerCompany < ApplicationRecord
  has_many :broker_company_identifiers
  has_many :loads

  def to_s
    name
  end
end
