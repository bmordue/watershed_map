# Palette's Journal - Watershed Map

## 2026-02-12 - Initial Observation of Watershed Map
**Learning:** The current interactive map is purely mouse-driven, making it inaccessible to keyboard users and screen readers.
- Watershed regions are `div` elements without `tabindex` or `role="button"`.
- There are no keyboard event listeners for selecting watersheds.
- The legend provides information but doesn't allow for interaction with the map, missing an opportunity for a more cohesive UX.
- Missing `:focus-visible` styles make navigation difficult for keyboard users.

**Action:** Implement keyboard accessibility (tabindex, roles, ARIA labels, keyboard listeners) and make the legend interactive to improve both accessibility and "delight".

## 2026-02-12 - Accessible Map Interactions
**Learning:** For interactive map visualizations, providing multiple paths to information (e.g., via the map directly or via an interactive legend) significantly enhances both accessibility for keyboard users and the overall user experience. Using `:focus-visible` ensures that visual focus indicators only appear for keyboard users, maintaining a clean look for mouse users.
**Action:** Always pair interactive map regions with an accessible legend/list that provides the same functionality.
