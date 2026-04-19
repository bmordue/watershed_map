## 2024-05-14 - Interactive Map Accessibility
**Learning:** For interactive HTML maps using `<rect>` or other SVG/SVG-like elements for hit areas, accessibility is often overlooked. Simply adding `role="button"` and `tabindex="0"` is not enough; one must also explicitly handle keyboard events (Enter/Space) and use high-contrast `:focus-visible` styles to ensure the focused element is clear against complex backgrounds.
**Action:** Always include keyboard event listeners and a distinctive focus outline (like gold #f1c40f) for interactive geographic regions.
