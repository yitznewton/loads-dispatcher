class BrokerCompany < ApplicationRecord
  has_many :broker_company_identifiers
  has_many :loads

  NAME_TQL = 'TQL'.freeze

  NAME_SUBSTITUTIONS = {
    'Ch Robinson Company' => 'CH Robinson',
    'Coyote Logistics Llc' => 'Coyote',
    'Schneider National Inc' => 'Schneider',
    'Total Quality Logistics Inc' => 'TQL'
  }.freeze

  def to_s
    NAME_SUBSTITUTIONS.fetch(name, name)
                      .delete_suffix(' INC')
                      .delete_suffix(' Inc')
                      .delete_suffix(' LLC')
                      .delete_suffix(' Llc')
                      .delete_suffix(' CO')
                      .delete_suffix(' Co')
                      .delete_suffix(' LP')
                      .delete_suffix(' Lp')
  end
end
