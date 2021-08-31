class BaseLoadFactory
  def initialize(load_data)
    @load_data = load_data
  end

  def self.call(load_data)
    new(load_data).call
  end

  attr_reader :load_data

  def call
    Load.transaction do
      load = find_or_create_load

      if load.valid?
        RawLoad.create!(data: load_data, load: load)
        next load
      else
        load_identifier.destroy!
        next nil
      end
    end
  end

  def find_or_create_load
    found_load = Load.find_by(load_identifier: load_identifier)

    if found_load
      found_load.update(load_attributes)
      found_load
    else
      Load.create(load_attributes.merge(load_identifier: load_identifier))
    end
  end

  def load_attributes
    parsed_attributes.merge(raw: load_data)
  end
end
