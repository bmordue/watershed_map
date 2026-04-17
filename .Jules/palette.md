## 2025-05-14 - Interactive Map Accessibility
**Learning:** Interactive map elements (like watershed regions) that rely solely on `click` events without semantic roles or keyboard listeners are inaccessible to keyboard users and invisible to screen readers. Implementing `role="button"`, `tabindex="0"`, and `aria-pressed` transforms a visual-only graphic into an inclusive interactive experience.
**Action:** Ensure all interactive SVG or Div-based visualization components include keyboard activation handlers and communicate state changes (like 'active' or 'selected') via ARIA attributes.
