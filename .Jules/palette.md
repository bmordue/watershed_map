## 2025-01-24 - Interactive Map Keyboard Accessibility
**Learning:** Interactive HTML map elements (like watershed regions) must include `role="button"`, `tabindex="0"`, focus-visible styles, and ARIA state attributes (like `aria-pressed`) to ensure accessibility for keyboard and screen reader users. Additionally, custom elements need explicit `keydown` listeners for 'Enter' and 'Space' to match standard button behavior.
**Action:** Always include keyboard event listeners and semantic ARIA roles when making non-button elements interactive.

## 2025-01-24 - State-Driven UI Synchronisation
**Learning:** UI state management (e.g., highlighting an active button) is more robust when driven by function parameters or application state rather than relying on the `event` object (e.g., `event.target`). This ensures that the UI remains consistent even when state changes are triggered programmatically (e.g., via a "Reset" button) rather than by direct user clicks.
**Action:** Refactor event-dependent UI updates to be state-driven or parameter-driven.
