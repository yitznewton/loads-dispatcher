namespace :old_data do
  desc 'Delete old raw_loads'
  task raw_loads: :environment do
    RawLoad.joins(:load).where('loads.updated_at < ?', Load.maximum(:updated_at) - 1.day).delete_all
  end

  desc 'Delete older load data'
  task delete_old_loads: :environment do
    Load.transaction do
      loads = Load.where(shortlisted_at: nil).where('updated_at < ?', Time.current - 18.hours)
      Rate.where(load_id: loads).delete_all
      loads.delete_all
    end
  end

  desc 'Delete all load data'
  task reset_loads: :environment do
    Load.transaction do
      RawLoad.delete_all
      Load.delete_all
    end
  end
end
