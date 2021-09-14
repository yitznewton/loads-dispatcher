class RefreshStatus
  KEY = :refresh_status

  def self.record(status:, time:, error: nil)
    meta_attributes = { value: { status: status, time: time, error: error.to_s } }

    if (meta = Meta.find_by(key: KEY))
      meta.update!(meta_attributes)
    else
      Meta.create!(meta_attributes.merge(key: KEY))
    end
  end

  def self.current
    meta = Meta.find_by(key: KEY)
    meta ? new(meta.value) : nil
  end

  def initialize(raw)
    @raw = raw
  end

  def status
    raw.fetch('status').to_sym
  end

  def time
    raw.fetch('time').to_time
  end

  def error
    raw.fetch('error')
  end

  def success?
    status == :success
  end

  def error?
    !success?
  end

  private

  attr_reader :raw
end
