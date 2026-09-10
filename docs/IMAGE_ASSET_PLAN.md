# Image asset plan

Bibo currently renders every product with generated placeholder SVGs
(`app/assets/images/products/placeholder-<category>.svg`, one flat icon per
category, reused across every product in that category and across both of a
product's `ProductImage` rows). They exist so the catalogue, gallery and
cart are fully functional and visually coherent, not as final artwork.

This plan lists the real photography Bibo would need to replace them, so a
future pass can drop files in and update seed data without redesigning
anything. It intentionally does not touch `docs/reference/` (local, gitignored
design references, not a source of production assets).

## Directory structure

Create one folder per product under `app/assets/images/products/`, named by
slug, holding 2 to 3 numbered images each:

```
app/assets/images/products/
  wave-catchall-bowl/
    01-main.jpg
    02-detail.jpg
  mushroom-table-lamp/
    01-main.jpg
    02-detail.jpg
    03-lifestyle.jpg
  glass-storage-jars/
    ...
```

Each product folder's images become that product's `ProductImage` rows (via
`image_path: "products/#{slug}/01-main.jpg"`), replacing the current shared
category SVG, ordered by their existing `position` column.

## Format and sizing

- **Format:** JPEG (photography) at quality ~85, or WebP if the pipeline is
  updated to serve it.
- **Dimensions:** 1600x1600px, delivered square (matches the `1:1`
  `aspect-ratio` already used by `.product-card__image`, `.gallery__main`
  and `.gallery__thumb` in `application.css`, so no CSS changes are needed).
- **Background:** consistent warm, uncluttered surface (linen, light oak,
  or plain warm-white) so products read well side by side in the grid.

## Shared visual direction

Warm daylight, cream and beige tones, natural wood and linen textures, soft
directional shadows, dusty accent colours (rose, olive, sage, terracotta)
appearing only via the product itself, not the backdrop. Editorial home
styling rather than a white e-commerce studio shot: a little context (a
book, a plant, a folded towel) is fine, clutter is not. No harsh flash, no
neon or saturated colours, no visible props from other unrelated product
categories.

## Per-product shot list

Each entry lists the target files, what they should show, and a
generation prompt (for an AI image tool) or art-direction brief (for a real
shoot) consistent with the direction above.

### Wave Catchall Bowl (`wave-catchall-bowl/`, Decor)
- `01-main.jpg`: bowl centred, empty, on a light wood surface.
- `02-detail.jpg`: bowl holding keys and a ring, closer crop.
- Prompt: "A softly rippled ceramic catchall bowl with a wave-edged rim, warm
  off-white matte glaze, sitting on pale oak wood in soft natural daylight,
  minimal styling, shallow depth of field, editorial home product photography."

### Mushroom Table Lamp (`mushroom-table-lamp/`, Lighting)
- `01-main.jpg`: lamp off, on a bedside table, neutral background.
- `02-detail.jpg`: lamp lit, warm glow, dim ambient room.
- `03-lifestyle.jpg`: lamp on a nightstand next to books, evening light.
- Prompt: "A mushroom-shaped glass table lamp with a rounded mouth-blown
  shade and weighted ceramic base, [cream / olive / dusty rose] colourway,
  warm ambient glow, styled on a wood nightstand, cozy editorial interior
  photography, soft shadows."

### Glass Storage Jars (`glass-storage-jars/`, Kitchen)
- `01-main.jpg`: the 3-jar set together, bamboo lids visible, on a counter.
- `02-detail.jpg`: single jar filled with pasta or oats, lid off to one side.
- `03-lifestyle.jpg`: jars on open kitchen shelving among other items.
- Prompt: "A set of glass storage jars with bamboo lids in [natural / walnut
  / black] tones, filled with pantry staples, on a warm stone or wood
  kitchen counter, soft daylight through a window, minimal styling."

### Stone Incense Holder (`stone-incense-holder/`, Decor)
- `01-main.jpg`: holder alone, unlit, on a plain warm surface.
- `02-detail.jpg`: incense stick burning, gentle smoke visible.
- Prompt: "A rounded pale stoneware incense holder with a curved ash-catching
  base, a thin trail of smoke from a lit incense stick, warm soft daylight,
  neutral uncluttered background, calm editorial still life."

### Minimal Shoe Rack (`minimal-shoe-rack/`, Organisation)
- `01-main.jpg`: empty rack, angled three-quarter view.
- `02-detail.jpg`: rack in an entryway with a few pairs of shoes.
- Prompt: "A three-tier slatted bamboo shoe rack in a bright entryway, one or
  two pairs of shoes styled neatly on it, warm natural light, clean wall
  background, editorial home photography."

### Acrylic Makeup Organiser (`acrylic-makeup-organiser/`, Bathroom)
- `01-main.jpg`: organiser empty on a vanity.
- `02-detail.jpg`: organiser styled with a few brushes and bottles.
- Prompt: "A clear acrylic multi-compartment makeup organiser on a bathroom
  vanity, softly filled with brushes and skincare bottles, warm daylight,
  light-toned counter, minimal styling, no visible branding on products."

### Oak Cutting Board (`oak-cutting-board/`, Kitchen)
- `01-main.jpg`: board alone, grain visible, on a counter.
- `02-detail.jpg`: board in use with sliced bread or vegetables.
- Prompt: "A solid oak cutting board with a carved handle and visible wood
  grain, resting on a warm kitchen counter with soft window light, styled
  with a few slices of bread, editorial food-adjacent still life."

### Ribbed Glass Mugs (`ribbed-glass-mugs/`, Kitchen)
- `01-main.jpg`: the set stacked or arranged together, empty.
- `02-detail.jpg`: one mug filled with coffee, steam visible.
- Prompt: "A set of textured ribbed glass mugs, some empty and one filled
  with coffee with gentle steam, warm morning daylight, wood table, minimal
  styling, shallow depth of field."

### Ceramic Soap Dispenser (`ceramic-soap-dispenser/`, Bathroom)
- `01-main.jpg`: dispenser alone on a bathroom counter.
- `02-detail.jpg`: close-up on the pump and glaze texture.
- Prompt: "A glazed ceramic soap dispenser with a stainless pump, in [cream /
  sage / dusty rose], on a light bathroom counter, soft natural light,
  minimal styling, small folded hand towel nearby."

### Cotton Towel Set (`cotton-towel-set/`, Textiles)
- `01-main.jpg`: hand towel and bath towel folded together.
- `02-detail.jpg`: towels hung on a rail, texture visible.
- Prompt: "A folded combed-cotton hand towel and bath towel in [cream / sage
  / dusty rose], stacked on a light wood shelf or hung on a rail, warm soft
  daylight, visible woven texture, calm bathroom styling."

### Ceramic Oil & Vinegar Set (`ceramic-oil-vinegar-set/`, Kitchen)
- `01-main.jpg`: both bottles together on a counter or table.
- `02-detail.jpg`: one bottle mid-pour.
- Prompt: "A matching pair of glazed ceramic oil and vinegar bottles with
  narrow pour spouts, on a kitchen counter or dining table, warm daylight,
  minimal styling, one bottle gently pouring."

### Soft Linen Cushion Cover (`soft-linen-cushion-cover/`, Textiles)
- `01-main.jpg`: cushion on a sofa or chair, natural light.
- `02-detail.jpg`: close-up on the linen weave and zip closure.
- Prompt: "A relaxed stonewashed linen cushion cover in [natural /
  terracotta / sage], propped on a neutral sofa or armchair, soft daylight,
  visible natural texture and drape, editorial home styling."

## After real images exist

1. Add the files under the paths above.
2. Update `db/seeds.rb`'s per-product `ProductImage` block to reference the
   new paths (and `alt_text`) instead of the shared category placeholder,
   keeping the existing `find_or_initialize_by(product:, position:)` pattern
   so re-running seeds stays idempotent.
3. The placeholder SVGs can stay as a fallback for any product that doesn't
   have real photography yet.
