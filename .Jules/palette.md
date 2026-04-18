## 2026-02-11 - Accessibility Enhancements for Interactive Watershed Map
**Learning:** Interactive HTML elements (like DIVs representing map regions) must have explicit ARIA roles, tabindex, and keyboard event listeners to be accessible to screen reader and keyboard-only users. Focus-visible styles are crucial for visual confirmation of navigation.
**Action:** Always add role="button", tabindex="0", and appropriate ARIA attributes (aria-label, aria-pressed) to custom interactive elements. Implement keyboard listeners for Enter and Space keys.
