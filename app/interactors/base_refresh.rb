class BaseRefresh
  def call
    touched_ids = []

    Load.transaction do
      City.routes.each do |(origin_city, destination_city)|
        data = response_body(origin_city: origin_city, destination_city: destination_city)
        raise response_exception_klass unless loads?(data)

        loads(data).each { |l| load_factory_klass.call(l).tap { |l| touched_ids << l&.id } }
      end

      load_board.load_identifiers.active.joins(:load).where.not(load: {id: touched_ids}).update_all(deleted_at: Time.current)
    end
  end
end
