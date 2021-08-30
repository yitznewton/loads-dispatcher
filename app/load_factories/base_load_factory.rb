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
      next Load.create(parsed_attributes.merge(load_identifier: load_identifier)) unless load

      load.update(parsed_attributes)

      next load if load.valid?

      load_identifier.destroy!
      next nil
    end
  end
end
