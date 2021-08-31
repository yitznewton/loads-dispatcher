class BrokerCompany < ApplicationRecord
  has_many :broker_company_identifiers, dependent: :destroy
  has_many :loads, dependent: :restrict_with_error

  NAME_TQL = 'TQL'.freeze

  NAME_SUBSTITUTIONS = {
    'Ch Robinson Company' => 'CH Robinson',
    'Coyote Logistics Llc' => 'Coyote',
    'Fitzmark Inc/Fitzmark Trucking Llc' => 'Fitzmark Trucking',
    'Globaltranz/Afn' => 'Globaltranz',
    'Jb Hunt Transport Services' => 'JB Hunt',
    'Jb Hunt Transport Services Inc' => 'JB Hunt',
    'NFI Logistics/NFI Transportation' => 'NFI',
    'Pepsi Logistics Company Inc' => 'Pepsi',
    'Pls Logistics Services' => 'PLS Logistics',
    'Png Logistics Company Llc' => 'PNG Logistics',
    'Quad Logistics Services Llc' => 'Quad Logistics',
    'R & R Express Logistics Inc/R & R Express Inc' => 'R & R Express',
    'Schneider National Inc' => 'Schneider',
    'Swift Logistics/Swift Transportation Company Of Az' => 'Swift',
    'Ta Brokerage Llc' => 'TA Brokerage',
    'Total Quality Logistics Inc' => 'TQL',
    'Us Xpress Inc' => 'US Xpress'
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
