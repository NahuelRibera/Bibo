import { Controller } from "@hotwired/stimulus"

// Product image gallery: clicking a thumbnail (or using prev/next) swaps
// the main image and updates which thumbnail is marked active. Works with
// any number of images, including a single one (nav controls disable
// themselves rather than being product-specific).
export default class extends Controller {
  static targets = ["main", "thumb", "prev", "next"]

  connect() {
    this.currentIndex = this.thumbTargets.findIndex((t) => t.classList.contains("is-active"))
    if (this.currentIndex === -1) this.currentIndex = 0
    this.updateNavState()
  }

  show(event) {
    const index = this.thumbTargets.indexOf(event.currentTarget)
    if (index === -1) return
    this.goTo(index)
  }

  previous() {
    this.goTo(this.currentIndex - 1)
  }

  next() {
    this.goTo(this.currentIndex + 1)
  }

  goTo(index) {
    if (index < 0 || index >= this.thumbTargets.length) return

    this.currentIndex = index
    const thumb = this.thumbTargets[index]

    this.mainTarget.src = thumb.dataset.fullSrc || thumb.querySelector("img").src
    this.mainTarget.alt = thumb.dataset.alt || ""

    this.thumbTargets.forEach((t, i) => t.classList.toggle("is-active", i === index))
    this.updateNavState()
  }

  updateNavState() {
    if (this.hasPrevTarget) this.prevTarget.disabled = this.currentIndex === 0
    if (this.hasNextTarget) this.nextTarget.disabled = this.currentIndex === this.thumbTargets.length - 1
  }
}
