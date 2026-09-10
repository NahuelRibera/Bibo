import { Controller } from "@hotwired/stimulus"

// A minimal accessible tabs pattern: manages aria-selected/tabindex on the
// tab buttons and hidden state on the panels, plus left/right arrow-key
// navigation between tabs per the WAI-ARIA authoring practices.
export default class extends Controller {
  static targets = ["tab", "panel"]

  select(event) {
    const tab = event.currentTarget
    this.activate(tab)
    tab.focus()
  }

  navigate(event) {
    const currentIndex = this.tabTargets.indexOf(event.currentTarget)
    if (currentIndex === -1) return

    let nextIndex = null
    if (event.key === "ArrowRight") nextIndex = (currentIndex + 1) % this.tabTargets.length
    if (event.key === "ArrowLeft") nextIndex = (currentIndex - 1 + this.tabTargets.length) % this.tabTargets.length
    if (event.key === "Home") nextIndex = 0
    if (event.key === "End") nextIndex = this.tabTargets.length - 1

    if (nextIndex === null) return

    event.preventDefault()
    const nextTab = this.tabTargets[nextIndex]
    this.activate(nextTab)
    nextTab.focus()
  }

  activate(tab) {
    const targetId = tab.getAttribute("aria-controls")

    this.tabTargets.forEach((t) => {
      const selected = t === tab
      t.setAttribute("aria-selected", selected ? "true" : "false")
      t.tabIndex = selected ? 0 : -1
    })

    this.panelTargets.forEach((panel) => {
      panel.hidden = panel.id !== targetId
    })
  }
}
