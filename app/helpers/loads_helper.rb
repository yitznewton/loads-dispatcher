module LoadsHelper
  def currency(raw, show_cents: true)
    return nil unless raw

    whole_dollars = raw.to_s[0...-2]
    cents = raw.to_s[-2..]
    show_cents ? "$#{whole_dollars}.#{cents}" : "$#{whole_dollars}"
  end

  def load_field(load, key, label = nil)
    value = key.is_a?(Symbol) ? load.send(key) : key
    label = key.to_s.humanize if !label

    tag.dt(label) + tag.dd(value)
  end

  def load_map(load)
    origin = "#{load.pickup_location.latitude},#{load.pickup_location.longitude}"
    destination = "#{load.dropoff_location.latitude},#{load.dropoff_location.longitude}"
    url = "https://www.google.com/maps/embed/v1/directions?origin=#{origin}&destination=#{destination}" \
          "&key=#{ENV['GOOGLE_MAPS_API_KEY']}"

    tag.iframe(nil, width: 800,
                    height: 400,
                    style: 'border: 0;',
                    loading: :lazy,
                    allowfullscreen: true,
                    src: raw(url)) # rubocop:todo Rails/OutputSafety
  end

  def shortlist_button(load)
    button_to 'Shortlist', shortlist_load_path(load),
              class: 'shortlist-button',
              form_class: ['shortlist-button-form', load.shortlisted? && 'hidden'],
              remote: true, form: { data: { load_id: load.id } }
  end

  def unshortlist_button(load)
    button_to 'Shortlisted', unshortlist_load_path(load),
              class: 'unshortlist-button',
              title: 'Click to un-shortlist', form_class: ['unshortlist-button-form', !load.shortlisted? && 'hidden'],
              remote: true, form: { data: { load_id: load.id } }
  end
end
