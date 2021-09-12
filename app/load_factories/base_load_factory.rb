class BaseLoadFactory
  def initialize(load_data)
    @load_data = load_data
  end

  def self.call(load_data)
    new(load_data).call
  end

  attr_reader :load_data

  # rubocop:disable Metrics/MethodLength
  def call
    Load.transaction do
      load = find_or_create_load

      if load.valid?
        load.load_identifier.undestroy!
        RawLoad.create!(data: load_data, load: load) if ENV['SAVE_RAW_LOADS']
        next load
      else
        load_identifier.destroy!
        next nil
      end
    end
  end
  # rubocop:enable Metrics/MethodLength

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
    parsed_attributes.compact.merge(raw: load_data, refreshed_at: Time.current)
  end
end
