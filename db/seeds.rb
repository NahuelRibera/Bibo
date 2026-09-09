# Repeatable seed data for Bibo. Safe to run multiple times: existing
# records are looked up by their natural key (slug/sku) and updated in
# place rather than duplicated.

CATEGORIES = [
  { slug: "storage",      name: "Storage",      description: "Baskets, jars and boxes for keeping everyday items tidy." },
  { slug: "decor",        name: "Decor",        description: "Small decorative pieces that bring warmth to a room." },
  { slug: "kitchen",      name: "Kitchen",      description: "Everyday tools and tableware for cooking and serving." },
  { slug: "bathroom",     name: "Bathroom",     description: "Simple accessories for a calmer bathroom routine." },
  { slug: "organisation", name: "Organisation", description: "Practical pieces that help everything find its place." },
  { slug: "lighting",     name: "Lighting",     description: "Warm, soft lighting for every corner of the home." },
  { slug: "textiles",     name: "Textiles",     description: "Cushions, towels and throws in natural materials." },
  { slug: "furniture",    name: "Furniture",    description: "Small furniture pieces for compact, everyday living." },
].freeze

categories = CATEGORIES.each_with_object({}) do |attrs, memo|
  category = Category.find_or_initialize_by(slug: attrs[:slug])
  category.update!(name: attrs[:name], description: attrs[:description])
  memo[attrs[:slug]] = category
end

puts "Seeded #{categories.size} categories"

REVIEW_TEMPLATES = [
  { rating: 5, title: "Exactly what I needed", body: "The %{name} looks even better in person and was easy to fit into our space. Good quality for the price." },
  { rating: 4, title: "Happy with this purchase", body: "Solid quality overall. The %{name} does the job well, though I wish it came in one more colour." },
  { rating: 5, title: "Great addition to the home", body: "Ordered the %{name} after seeing it online and it did not disappoint. Arrived well packaged and looks great on the shelf." },
  { rating: 3, title: "Good but not perfect", body: "The %{name} is nice but a little smaller than I expected from the photos. Still useful though." },
  { rating: 5, title: "Would buy again", body: "This is my second order from Bibo. The %{name} is well made and matches the rest of our home nicely." },
  { rating: 4, title: "Nice everyday piece", body: "Simple, functional and looks good. The %{name} has held up well after a few weeks of daily use." },
].freeze

REVIEWER_NAMES = [
  "Emma L.", "Daniel K.", "Sofia M.", "Noah B.", "Isabelle R.", "Lucas P.",
  "Anna S.", "Mark T.", "Julia W.", "Thomas H.", "Clara V.", "Ben O.",
].freeze

SHIPPING_RETURNS_TEXT = "Free shipping on orders over €40, otherwise a flat €4.99. " \
  "Orders are delivered within 3-5 working days. Unused items in their original packaging " \
  "can be returned within 30 days for a full refund."

PRODUCTS = [
  {
    slug: "wave-catchall-bowl",
    name: "Wave Catchall Bowl",
    category: "decor",
    code: "WCB",
    base_price_cents: 1499,
    short_description: "A softly rippled ceramic bowl for keys, jewellery and other small everyday items.",
    description: "This catchall bowl has a gently waved rim and a matte glaze that catches the light. " \
      "Keep it by the front door for keys and coins, or on a shelf for rings and trinkets. Each piece is " \
      "cast from a stoneware mould, so subtle variations in the rim are part of the design.",
    details: "Glazed stoneware. Diameter 16cm, height 5cm. Hand wash recommended.",
    featured: true,
    trending: true,
    variants: [{ colour: nil, option_label: nil, price_cents: 1499, stock: 40 }],
  },
  {
    slug: "mushroom-table-lamp",
    name: "Mushroom Table Lamp",
    category: "lighting",
    code: "MTL",
    base_price_cents: 2499,
    short_description: "A compact glass table lamp with a soft, rounded mushroom-style shade.",
    description: "The Mushroom Table Lamp gives off a warm, diffused glow that works well on a bedside " \
      "table or reading corner. The glass shade is mouth-blown and paired with a weighted ceramic base " \
      "so it sits steadily on any surface.",
    details: "Glass shade, ceramic base. Height 26cm. E14 bulb included. 1.8m fabric cable.",
    featured: true,
    trending: true,
    variants: [
      { colour: "Cream", option_label: nil, price_cents: 2499, stock: 20 },
      { colour: "Olive", option_label: nil, price_cents: 2499, stock: 18 },
      { colour: "Dusty Rose", option_label: nil, price_cents: 2499, stock: 15 },
    ],
  },
  {
    slug: "glass-storage-jars",
    name: "Glass Storage Jars",
    category: "kitchen",
    code: "GSJ",
    base_price_cents: 1999,
    short_description: "Airtight glass jars with bamboo lids, ideal for cereals, pasta, coffee and more.",
    description: "Keep your kitchen organised with this set of glass storage jars. The bamboo lids have " \
      "a silicone seal that keeps contents fresh for longer, and the clear glass makes it easy to see " \
      "what's inside. The minimal design fits neatly on open shelving or inside a cupboard.",
    details: "Borosilicate glass with bamboo lid and silicone seal. Dishwasher safe (jar only).",
    featured: true,
    trending: true,
    variants: [
      { colour: "Natural", option_label: "Set of 2", price_cents: 1999, stock: 25 },
      { colour: "Walnut",  option_label: "Set of 2", price_cents: 1999, stock: 22 },
      { colour: "Black",   option_label: "Set of 2", price_cents: 1999, stock: 20 },
      { colour: "Natural", option_label: "Set of 3", price_cents: 2499, stock: 20 },
      { colour: "Walnut",  option_label: "Set of 3", price_cents: 2499, stock: 18 },
      { colour: "Black",   option_label: "Set of 3", price_cents: 2499, stock: 16 },
      { colour: "Natural", option_label: "Set of 4", price_cents: 2999, stock: 15 },
      { colour: "Walnut",  option_label: "Set of 4", price_cents: 2999, stock: 12 },
      { colour: "Black",   option_label: "Set of 4", price_cents: 2999, stock: 10 },
    ],
  },
  {
    slug: "stone-incense-holder",
    name: "Stone Incense Holder",
    category: "decor",
    code: "SIH",
    base_price_cents: 1299,
    short_description: "A rounded stoneware incense holder with a built-in ash catcher.",
    description: "This incense holder is cast from pale stoneware with a smooth, hand-finished surface. " \
      "The curved shape catches falling ash, so it can sit safely on a shelf, desk or windowsill.",
    details: "Stoneware. Length 12cm. Fits standard incense sticks. Wipe clean.",
    featured: false,
    trending: true,
    variants: [{ colour: nil, option_label: nil, price_cents: 1299, stock: 50 }],
  },
  {
    slug: "minimal-shoe-rack",
    name: "Minimal Shoe Rack",
    category: "organisation",
    code: "MSR",
    base_price_cents: 2999,
    short_description: "A three-tier bamboo shoe rack that fits neatly into an entryway or hallway.",
    description: "This shoe rack holds up to nine pairs of shoes across three slatted tiers, keeping an " \
      "entryway clear without taking up much floor space. The natural bamboo frame is lightweight but " \
      "sturdy, and requires only simple assembly.",
    details: "Bamboo frame. 60cm wide x 28cm deep x 45cm tall. Holds up to 9 pairs. Flat-packed.",
    featured: false,
    trending: true,
    variants: [{ colour: nil, option_label: nil, price_cents: 2999, stock: 15 }],
  },
  {
    slug: "acrylic-makeup-organiser",
    name: "Acrylic Makeup Organiser",
    category: "bathroom",
    code: "AMO",
    base_price_cents: 2299,
    short_description: "A clear multi-compartment organiser for makeup, brushes and skincare.",
    description: "Keep everyday makeup and skincare visible and within reach with this clear acrylic " \
      "organiser. The mix of drawers and open compartments suits brushes, palettes and smaller bottles, " \
      "and the sturdy base keeps it stable on a bathroom counter or vanity.",
    details: "Acrylic. 26cm wide x 14cm deep x 16cm tall. Two drawers, three open compartments.",
    featured: false,
    trending: true,
    variants: [{ colour: nil, option_label: nil, price_cents: 2299, stock: 20 }],
  },
  {
    slug: "oak-cutting-board",
    name: "Oak Cutting Board",
    category: "kitchen",
    code: "OCB",
    base_price_cents: 1899,
    short_description: "A solid oak cutting board with a carved handle, finished with food-safe oil.",
    description: "This cutting board is made from a single piece of solid oak and finished with a " \
      "food-safe oil that highlights the natural grain. The carved handle makes it easy to move from " \
      "counter to table, and it's just as suited to serving cheese and bread as it is to prepping food.",
    details: "Solid oak, food-safe oil finish. 35cm x 20cm x 2cm. Hand wash and re-oil occasionally.",
    featured: false,
    trending: true,
    variants: [{ colour: nil, option_label: nil, price_cents: 1899, stock: 25 }],
  },
  {
    slug: "ribbed-glass-mugs",
    name: "Ribbed Glass Mugs",
    category: "kitchen",
    code: "RGM",
    base_price_cents: 1699,
    short_description: "Textured glass mugs with a ribbed exterior, sold in sets.",
    description: "These ribbed glass mugs work equally well for coffee, tea or a cold drink. The textured " \
      "exterior stays cool to the touch even with a hot drink inside, and the simple shape stacks neatly " \
      "in a cupboard.",
    details: "Borosilicate glass. Holds 280ml. Dishwasher and microwave safe.",
    featured: true,
    trending: true,
    variants: [
      { colour: nil, option_label: "Set of 2", price_cents: 1699, stock: 30 },
      { colour: nil, option_label: "Set of 4", price_cents: 2999, stock: 22 },
      { colour: nil, option_label: "Set of 6", price_cents: 3999, stock: 14 },
    ],
  },
  {
    slug: "ceramic-soap-dispenser",
    name: "Ceramic Soap Dispenser",
    category: "bathroom",
    code: "CSD",
    base_price_cents: 1399,
    short_description: "A refillable ceramic soap dispenser with a rust-resistant pump.",
    description: "This soap dispenser has a smooth, glazed ceramic body and a rust-resistant pump that's " \
      "built to handle daily use at the sink. It's designed to be refilled rather than replaced, and pairs " \
      "well with the rest of the bathroom accessories.",
    details: "Glazed ceramic, stainless steel pump. Holds 350ml. Hand wash the body only.",
    featured: true,
    trending: false,
    variants: [
      { colour: "Cream",      option_label: nil, price_cents: 1399, stock: 30 },
      { colour: "Sage",       option_label: nil, price_cents: 1399, stock: 28 },
      { colour: "Dusty Rose", option_label: nil, price_cents: 1399, stock: 24 },
    ],
  },
  {
    slug: "cotton-towel-set",
    name: "Cotton Towel Set",
    category: "textiles",
    code: "CTS",
    base_price_cents: 2499,
    short_description: "A set of soft combed-cotton towels in a hand towel and bath towel size.",
    description: "Woven from combed cotton for softness that holds up over repeated washes, this towel " \
      "set includes one hand towel and one bath towel. The plain weave and muted colourway keep them " \
      "easy to coordinate with the rest of a bathroom.",
    details: "100% combed cotton, 550gsm. Includes 1 hand towel (50x90cm) and 1 bath towel (70x140cm). Machine washable.",
    featured: true,
    trending: false,
    variants: [
      { colour: "Cream",      option_label: nil, price_cents: 2499, stock: 20 },
      { colour: "Sage",       option_label: nil, price_cents: 2499, stock: 18 },
      { colour: "Dusty Rose", option_label: nil, price_cents: 2499, stock: 16 },
    ],
  },
  {
    slug: "ceramic-oil-vinegar-set",
    name: "Ceramic Oil & Vinegar Set",
    category: "kitchen",
    code: "COV",
    base_price_cents: 1799,
    short_description: "A matching pair of ceramic bottles for everyday oil and vinegar.",
    description: "This pair of ceramic bottles is sized for everyday use at the stove or table. Each " \
      "bottle has a narrow pour spout that controls the flow without dripping, and the matte glaze wipes " \
      "clean easily.",
    details: "Glazed stoneware. Each bottle holds 250ml. Hand wash recommended.",
    featured: false,
    trending: false,
    variants: [{ colour: nil, option_label: nil, price_cents: 1799, stock: 30 }],
  },
  {
    slug: "soft-linen-cushion-cover",
    name: "Soft Linen Cushion Cover",
    category: "textiles",
    code: "SLC",
    base_price_cents: 1599,
    short_description: "A relaxed-fit linen cushion cover with a hidden zip closure.",
    description: "Made from a stonewashed linen blend, this cushion cover has a relaxed drape and softens " \
      "further with every wash. A hidden zip keeps the closure out of sight, and the natural texture pairs " \
      "well with both warm and neutral tones.",
    details: "55% linen, 45% cotton. Fits a 45x45cm cushion insert (insert not included). Machine washable.",
    featured: false,
    trending: false,
    variants: [
      { colour: "Natural",    option_label: nil, price_cents: 1599, stock: 25 },
      { colour: "Terracotta", option_label: nil, price_cents: 1599, stock: 22 },
      { colour: "Sage",       option_label: nil, price_cents: 1599, stock: 20 },
    ],
  },
].freeze

def slugify(text)
  text.to_s.gsub(/[^a-zA-Z0-9]+/, "-").upcase
end

PRODUCTS.each_with_index do |attrs, index|
  category = categories.fetch(attrs[:category])

  product = Product.find_or_initialize_by(slug: attrs[:slug])
  product.update!(
    category: category,
    name: attrs[:name],
    short_description: attrs[:short_description],
    description: attrs[:description],
    details: attrs[:details],
    shipping_returns_text: SHIPPING_RETURNS_TEXT,
    base_price_cents: attrs[:base_price_cents],
    featured: attrs[:featured],
    trending: attrs[:trending],
    active: true
  )

  attrs[:variants].each do |variant_attrs|
    size_code = variant_attrs[:option_label] ? slugify(variant_attrs[:option_label].sub("Set of ", "S")) : nil
    colour_code = variant_attrs[:colour] ? slugify(variant_attrs[:colour])[0, 3] : nil
    suffix = [size_code, colour_code].compact
    suffix = ["STD"] if suffix.empty?
    sku = "BIBO-#{attrs[:code]}-#{suffix.join('-')}"

    variant = ProductVariant.find_or_initialize_by(product: product, sku: sku)
    variant.update!(
      colour: variant_attrs[:colour],
      option_label: variant_attrs[:option_label],
      price_cents: variant_attrs[:price_cents],
      stock: variant_attrs[:stock],
      active: true
    )
  end

  placeholder = "products/placeholder-#{attrs[:category]}.svg"
  [0, 1].each do |position|
    image = ProductImage.find_or_initialize_by(product: product, position: position)
    image.update!(image_path: placeholder, alt_text: "#{attrs[:name]} product photo")
  end

  if product.reviews.none?
    3.times do |n|
      template = REVIEW_TEMPLATES[(index + n) % REVIEW_TEMPLATES.size]
      reviewer = REVIEWER_NAMES[(index * 3 + n) % REVIEWER_NAMES.size]

      Review.create!(
        product: product,
        reviewer_name: reviewer,
        title: template[:title],
        body: format(template[:body], name: attrs[:name]),
        rating: template[:rating]
      )
    end
  end
end

puts "Seeded #{Product.count} products, #{ProductVariant.count} variants, #{ProductImage.count} images, #{Review.count} reviews"
