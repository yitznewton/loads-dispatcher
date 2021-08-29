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
      load = Load.find_by(load_identifier: load_identifier)

      if load
        load.update(parsed_attributes)
        load.destroy unless load.valid?
        next
      end

      Load.create(parsed_attributes.merge(load_identifier: load_identifier))
    end
  end
end
