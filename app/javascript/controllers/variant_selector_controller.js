import { Controller } from "@hotwired/stimulus"

// Drives the price, stock note and add-to-cart button from the currently
// selected <option>'s data attributes. Works for any product regardless of
// which option fields (colour, size...) its variants use.
export default class extends Controller {
  static targets = ["select", "price", "stockNote", "submit", "quantity"]

  connect() {
    this.update()
  }

  update() {
    const option = this.selectTarget.selectedOptions[0]
    if (!option) return

    this.priceTarget.textContent = option.dataset.price

    const stock = parseInt(option.dataset.stock, 10) || 0
    const purchasable = option.dataset.purchasable === "true"

    if (!purchasable || stock <= 0) {
      this.stockNoteTarget.textContent = "Out of stock"
      this.stockNoteTarget.className = "stock-note stock-note--out"
      this.submitTarget.disabled = true
    } else if (stock <= 5) {
      this.stockNoteTarget.textContent = `Only ${stock} left in stock`
      this.stockNoteTarget.className = "stock-note stock-note--low"
      this.submitTarget.disabled = false
    } else {
      this.stockNoteTarget.textContent = "In stock"
      this.stockNoteTarget.className = "stock-note"
      this.submitTarget.disabled = false
    }

    if (this.hasQuantityTarget) {
      this.quantityTarget.max = Math.max(stock, 1)
      if (parseInt(this.quantityTarget.value, 10) > stock) {
        this.quantityTarget.value = Math.max(stock, 1)
      }
    }
  }
}
