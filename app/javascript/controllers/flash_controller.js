import { Controller } from "@hotwired/stimulus"

// Auto-dismisses flash messages after a short delay. Purely cosmetic: the
// message is already in the DOM on load, this just fades it out later.
export default class extends Controller {
  static targets = ["message"]
  static values = { delay: { type: Number, default: 4000 } }

  connect() {
    if (!this.hasMessageTarget) return
    this.timeout = setTimeout(() => this.dismiss(), this.delayValue)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  dismiss() {
    this.messageTargets.forEach((el) => {
      el.classList.add("is-dismissing")
      el.addEventListener("transitionend", () => el.remove(), { once: true })
    })
  }
}
