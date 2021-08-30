class BrokerCompany < ApplicationRecord
  has_many :broker_company_identifiers, dependent: :destroy
  has_many :loads, dependent: :restrict_with_error

  NAME_TQL = 'TQL'.freeze

  NAME_SUBSTITUTIONS = {
    'Ch Robinson Company' => 'CH Robinson',
    'Coyote Logistics Llc' => 'Coyote',
    'Jb Hunt Transport Services' => 'JB Hunt',
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
