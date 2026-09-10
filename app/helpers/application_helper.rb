module ApplicationHelper
  # Formats integer cents as European-style euros, e.g. 1999 => "€19,99"
  def euro_price(cents)
    number_to_currency(cents.to_i / 100.0, unit: "€", separator: ",", delimiter: ".", format: "%u%n")
  end

  ICON_PATHS = {
    search: '<circle cx="11" cy="11" r="7"/><path d="m21 21-4.6-4.6" stroke-linecap="round"/>',
    heart: '<path d="M12 20.6s-7.3-4.4-9.8-8.9C.6 8.4 1.6 4.9 5 3.9c2.2-.6 4.3.3 5.4 2C11.5 4.2 13.6 3.3 15.8 3.9c3.4 1 4.4 4.5 2.8 7.8C16 16.2 12 20.6 12 20.6Z"/>',
    bag: '<path d="M6 8h12l1 12.5a1 1 0 0 1-1 1.1H6a1 1 0 0 1-1-1.1L6 8Z"/><path d="M9 8V6a3 3 0 0 1 6 0v2" fill="none"/>',
    user: '<circle cx="12" cy="8" r="3.6" fill="none"/><path d="M4.5 20.2a7.5 7.5 0 0 1 15 0" fill="none"/>',
    menu: '<path d="M4 7h16M4 12h16M4 17h16" stroke-linecap="round"/>',
    close: '<path d="m6 6 12 12M18 6 6 18" stroke-linecap="round"/>',
    chevron_left: '<path d="M15 5 8 12l7 7" fill="none" stroke-linecap="round" stroke-linejoin="round"/>',
    chevron_right: '<path d="m9 5 7 7-7 7" fill="none" stroke-linecap="round" stroke-linejoin="round"/>',
    star: '<path d="m12 3 2.8 5.9 6.4.7-4.8 4.5 1.3 6.4L12 17.6 6.3 20.5l1.3-6.4-4.8-4.5 6.4-.7Z"/>',
    plus: '<path d="M12 5v14M5 12h14" stroke-linecap="round"/>',
    minus: '<path d="M5 12h14" stroke-linecap="round"/>',
    check: '<path d="m5 12 5 5 9-10" fill="none" stroke-linecap="round" stroke-linejoin="round"/>',
  }.freeze

  # One simple line icon per seeded category, keyed by slug, so the home
  # page's quick-category chips stay generic rather than hardcoding markup
  # per category name.
  CATEGORY_ICON_PATHS = {
    # Bold, mostly-closed shapes on purpose: thin, separated line segments
    # (an earlier furniture glyph made of two lone vertical strokes) all but
    # disappear once scaled down to a 28px chip icon.
    "storage" => '<rect x="4" y="6" width="16" height="14" rx="1.5" fill="none"/><path d="M4 11h16" fill="none"/>',
    "decor" => '<rect x="4" y="4" width="16" height="16" rx="2" fill="none"/><circle cx="9" cy="9" r="1.4"/><path d="M5 16l4.5-5 3 3 3-4 4.5 6" fill="none"/>',
    "kitchen" => '<path d="M5 6h11v9a4 4 0 0 1-4 4H9a4 4 0 0 1-4-4V6Z" fill="none"/><path d="M16 8h2a2 2 0 0 1 0 4h-2" fill="none"/>',
    "bathroom" => '<path d="M12 3s6 6.5 6 11a6 6 0 0 1-12 0c0-4.5 6-11 6-11Z" fill="none"/>',
    "organisation" => '<rect x="4" y="4" width="7" height="7" rx="1" fill="none"/><rect x="13" y="4" width="7" height="7" rx="1" fill="none"/><rect x="4" y="13" width="7" height="7" rx="1" fill="none"/><rect x="13" y="13" width="7" height="7" rx="1" fill="none"/>',
    "lighting" => '<path d="M12 3a6 6 0 0 0-3.5 10.9c.6.5 1 1.2 1 2.1h5c0-.9.4-1.6 1-2.1A6 6 0 0 0 12 3Z" fill="none"/><path d="M9.5 18.5h5M10.3 21h3.4" fill="none"/>',
    "textiles" => '<rect x="5" y="7" width="14" height="12" rx="4" fill="none"/><path d="M9 13h6" fill="none"/>',
    "furniture" => '<rect x="6" y="4" width="12" height="8" rx="1" fill="none"/><path d="M6 12v7M18 12v7" fill="none"/>',
  }.freeze

  def category_icon(slug, size: 28)
    path = CATEGORY_ICON_PATHS.fetch(slug, CATEGORY_ICON_PATHS["decor"])

    content_tag(:svg, width: size, height: size, viewBox: "0 0 24 24",
                fill: "none", stroke: "currentColor", "stroke-width": 1.7, "stroke-linecap": "round",
                "aria-hidden": "true", focusable: "false") do
      raw(path) # rubocop:disable Rails/OutputSafety
    end
  end

  # Small inline icon set so the storefront doesn't need an icon-font or JS
  # icon library for a handful of glyphs. `filled: true` switches a
  # stroke-only icon (search, chevrons...) to a solid fill (heart, star).
  def icon(name, filled: false, size: 20)
    path = ICON_PATHS.fetch(name) { raise ArgumentError, "unknown icon #{name}" }

    content_tag(:svg, class: "icon", width: size, height: size, viewBox: "0 0 24 24",
                fill: filled ? "currentColor" : "none",
                stroke: filled ? "none" : "currentColor",
                "stroke-width": filled ? nil : 1.6,
                "aria-hidden": "true", focusable: "false") do
      raw(path) # rubocop:disable Rails/OutputSafety
    end
  end

  def star_rating(rating)
    filled = rating.to_f.round
    content_tag(:span, class: "star-rating", aria: { hidden: "true" } ) do
      safe_join((1..5).map { |n| icon(:star, filled: n <= filled, size: 14) })
    end
  end
end
