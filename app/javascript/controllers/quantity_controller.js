import { Controller } from "@hotwired/stimulus"

// A polished +/- stepper around a native number input. This only offers a
// convenient way to edit the value client-side — the server still clamps
// quantity to available stock and a minimum of 1 when the form is submitted,
// so nothing here is trusted as authoritative.
export default class extends Controller {
  static targets = ["input"]

  increment() {
    this.setValue(this.currentValue + 1)
  }

  decrement() {
    this.setValue(this.currentValue - 1)
  }

  get currentValue() {
    return parseInt(this.inputTarget.value, 10) || this.min
  }

  get min() {
    return parseInt(this.inputTarget.min, 10) || 1
  }

  get max() {
    const max = parseInt(this.inputTarget.max, 10)
    return Number.isNaN(max) ? Infinity : max
  }

  setValue(value) {
    value = Math.min(Math.max(value, this.min), this.max)
    this.inputTarget.value = value
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }
}
