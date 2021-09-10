module LoadsHelper
  DATE_TEMPLATE = '%a %-m/%-d %H:%M'.freeze

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

  def pickup_date_display(load)
    load.immediate_pickup? ? 'Immediate' : date_display(load.pickup_date)
  end

  def date_display(date)
    date&.strftime(DATE_TEMPLATE)
  end

  def phone_link(load)
    load.contact_phone && phone_to(load.contact_phone, number_to_phone(load.contact_phone))
  end

  def email_link(load)
    mail_to(load.contact_email, load.contact_email || 'compose email',
            subject: email_subject(load),
            body: email_body(load))
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

      Regarding load reference number #{load.reference_number}, I have a 26' box truck in the area with an experienced CDL driver. Our ETA to the shipper's location (#{load.pickup_location}) is ________. I can deliver this load for you for $________.

      Have a great day!
      --
      Peter Holmes, Dispatcher
      973-572-7541

      Milton Morley Transport
      USDOT 3707404
      MC 1299745
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
