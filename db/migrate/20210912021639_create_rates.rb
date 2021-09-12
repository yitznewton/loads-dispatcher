class CreateRates < ActiveRecord::Migration[6.1]
  def up
    create_table :rates do |t|
      t.integer :rate
      t.references :load, null: false, foreign_key: true

      t.timestamps
    end

    say_with_time 'Backfilling rates table' do
      Load.all.each { |load| (load.rates << Rate.new(rate: load.rate) && load.save) if load.rate }
    end
  end

  def down
    drop_table :rates
  end
end
