FactoryBot.define do
  factory :load do
    pickup_date { Time.current }
    pickup_location { { city: 'Passaic', state: 'NJ', county: 'Passaic' } }
    dropoff_location { { city: 'West Hartford', state: 'CT', county: 'Hartford' } }
    weight { 5000 }
    rate { 20_000 }
    distance { 100 }
    broker_company
    load_identifier
  end
end
