namespace :old_data do
  desc 'Delete old raw_loads'
  task raw_loads: :environment do
    RawLoad.joins(:load).where('loads.updated_at < ?', Load.maximum(:updated_at) - 1.day).delete_all
  end
end
