## 2026-04-16 - [Keyboard Accessibility for Interactive GIS Maps]
**Learning:** Interactive maps built using div/svg elements often lack native keyboard support. Explicitly adding `tabindex`, `role="button"`, and handling `keydown` events (Enter/Space) is crucial for making geospatial data accessible to all users.
**Action:** Always include keyboard event listeners and ARIA roles when creating interactive map components.
