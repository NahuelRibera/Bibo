import { Controller } from "@hotwired/stimulus"

// Drives price, stock and the submitted variant id from whichever option
// axes (size, colour...) a product actually has. Each axis is rendered as
// a native radio group; a hidden axis (only one possible value) still gets
// a single checked radio so the matching logic below never has to special
// case it. The exact variant is looked up from `variantsValue`, a JSON
// array rendered server-side from the product's real ProductVariant rows —
// nothing here is specific to any one product.
export default class extends Controller {
  static targets = ["sizeOption", "colourOption", "variantId", "price", "stockNote", "submit", "quantity"]
  static values = { variants: Array }

  connect() {
    this.update()
  }

  update() {
    const size = this.checkedValue(this.sizeOptionTargets)
    const colour = this.checkedValue(this.colourOptionTargets)
    const variant = this.variantsValue.find((v) => v.size === size && v.colour === colour)

    this.currentVariant = variant

    if (!variant) {
      this.variantIdTarget.value = ""
      this.priceTarget.textContent = "Not available"
      this.stockNoteTarget.textContent = "This combination isn't available"
      this.stockNoteTarget.className = "stock-note stock-note--out"
      this.submitTarget.disabled = true
      return
    }

    this.variantIdTarget.value = variant.id
    this.priceTarget.textContent = variant.price_display

    if (!variant.purchasable || variant.stock <= 0) {
      this.stockNoteTarget.textContent = "Out of stock"
      this.stockNoteTarget.className = "stock-note stock-note--out"
      this.submitTarget.disabled = true
    } else if (variant.stock <= 5) {
      this.stockNoteTarget.textContent = `Only ${variant.stock} left in stock`
      this.stockNoteTarget.className = "stock-note stock-note--low"
      this.submitTarget.disabled = false
    } else {
      this.stockNoteTarget.textContent = "In stock, ready to ship"
      this.stockNoteTarget.className = "stock-note"
      this.submitTarget.disabled = false
    }

    if (this.hasQuantityTarget) {
      this.quantityTarget.max = Math.max(variant.stock, 1)
      if (parseInt(this.quantityTarget.value, 10) > variant.stock) {
        this.quantityTarget.value = Math.max(variant.stock, 1)
      }
    }
  }

  checkedValue(targets) {
    if (targets.length === 0) return ""
    return targets.find((el) => el.checked)?.value ?? ""
  }
}
