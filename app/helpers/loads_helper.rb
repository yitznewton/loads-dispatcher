module LoadsHelper
  def place(place)
    place.slice('city', 'state').values.join(', ')
  end

  def currency(raw, show_cents: true)
    return nil unless raw

    whole_dollars = raw.to_s[0...-2]
    cents = raw.to_s[-2..]
    show_cents ? "#{whole_dollars}.#{cents}" : whole_dollars
  end
end
