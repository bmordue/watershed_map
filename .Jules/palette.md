## 2026-02-27 - Keyboard Accessibility for Interactive Map Regions
**Learning:** Custom interactive regions (like DIV-based map overlays) are completely invisible to keyboard users and screen readers unless explicitly given a `role="button"`, `tabindex="0"`, and keyboard event listeners. `:focus-visible` is essential for providing feedback without affecting mouse users.
**Action:** Always include ARIA roles and keyboard event listeners for non-semantic interactive elements, and use high-contrast focus indicators with `z-index` to ensure visibility.
