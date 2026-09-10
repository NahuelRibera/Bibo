import { Controller } from "@hotwired/stimulus"

// Submits the controller's form when a filter/sort control changes, so the
// catalogue toolbar's selects apply immediately without a separate button.
// The form still works with no JS at all via its own submit button.
export default class extends Controller {
  submit() {
    this.element.requestSubmit()
  }
}
