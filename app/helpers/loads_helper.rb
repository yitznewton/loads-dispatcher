module LoadsHelper
  def currency(raw, show_cents: true)
    return nil unless raw

    whole_dollars = raw.to_s[0...-2]
    cents = raw.to_s[-2..]
    show_cents ? "$#{whole_dollars}.#{cents}" : "$#{whole_dollars}"
  end

  def load_field(load, key, label = nil, &block)
    value = if block.present?
              capture(&block)
            elsif key.is_a?(Symbol)
              load.send(key)
            else
              key
            end

    label = key.to_s.humanize if !label

    tag.dt(label) + tag.dd(value)
  end

  def broker_data(load)
    # rubocop:todo Rails/OutputSafety
    raw([load.broker_company, load.contact_name, phone_link(load), email_link(load)].compact.join(' - '))
    # rubocop:enable Rails/OutputSafety
  end

  def phone_link(load)
    load.contact_phone && phone_to(load.contact_phone, number_to_phone(load.contact_phone))
  end

  def email_link(load)
    email_url = URI('https://mail.google.com/mail')

    email_url.query = {
      view: :cm,
      su: email_subject(load),
      to: load.contact_email,
      body: email_body(load)
    }.to_query

    link_to(load.contact_email || 'compose email', email_url.to_s, target: 'dispatcher_email')
  end

  def email_subject(load)
    "Offer to deliver ref# #{load.reference_number} (#{load.pickup_location} to #{load.dropoff_location})"
  end

  def email_body(load)
    <<~EOF
      Posted rate: #{currency(load.rate, show_cents: false)}
      Broker: #{load.broker_company}
      Notes: #{load.notes}

      Dear #{load.contact_name || '_____'}:

      Regarding load reference number #{load.reference_number}, I have a 26' box truck in the area with a highly qualified CDL driver. Our ETA to the shipper's location (#{load.pickup_location}) is ________. I can deliver this load for you for $________.

      Have a great day!
      --
      Peter Holmes, Dispatcher
      Milton Morley Transport
      973-572-7541
    EOF
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
