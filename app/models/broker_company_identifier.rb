class BrokerCompanyIdentifier < ApplicationRecord
  belongs_to :broker_company
  belongs_to :load_board
end
