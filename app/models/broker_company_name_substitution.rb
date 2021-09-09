class BrokerCompanyNameSubstitution < ApplicationRecord
  CACHE_KEY = 'broker_company_name_substitutions'.freeze

  after_save :invalidate_cache

  validates :before, uniqueness: true

  def self.to_h
    Rails.cache.fetch(CACHE_KEY) do
      all.pluck(:before, :after).to_h
    end
  end

  def invalidate_cache
    Rails.cache.delete(CACHE_KEY)
  end
end
