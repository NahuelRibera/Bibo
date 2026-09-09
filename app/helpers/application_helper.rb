module ApplicationHelper
  # Formats integer cents as European-style euros, e.g. 1999 => "€19,99"
  def euro_price(cents)
    number_to_currency(cents.to_i / 100.0, unit: "€", separator: ",", delimiter: ".", format: "%u%n")
  end
end
