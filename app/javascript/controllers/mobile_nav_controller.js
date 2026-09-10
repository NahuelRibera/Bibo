import { Controller } from "@hotwired/stimulus"

// A simple slide-in drawer for small screens. Keyboard users can open it
// with Enter/Space (native button behaviour) and close it with Escape;
// nothing about it depends on hover. Scoped to <body> (rather than the
// drawer element itself) because the toggle button lives in the header,
// outside the drawer's own markup — a Stimulus action only binds within
// its controller's DOM subtree.
export default class extends Controller {
  static targets = ["drawer", "panel"]

  close() {
    this.drawerTarget.dataset.open = "false"
    document.body.style.overflow = ""
  }

  open() {
    this.drawerTarget.dataset.open = "true"
    document.body.style.overflow = "hidden"
    this.panelTarget.querySelector("a, button, input")?.focus()
  }

  keydown(event) {
    if (event.key === "Escape") this.close()
  }

  connect() {
    this.boundKeydown = this.keydown.bind(this)
    document.addEventListener("keydown", this.boundKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundKeydown)
  }
}
