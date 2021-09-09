class BrokerCompany < ApplicationRecord
  has_many :broker_company_identifiers, dependent: :destroy
  has_many :loads, dependent: :restrict_with_error

  NAME_TQL = 'TQL'.freeze

  def to_s
    BrokerCompanyNameSubstitution.to_h.fetch(name, name)
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
