# Palette's Journal - Critical UX/Accessibility Learnings

## 2025-05-15 - Interactive Map Keyboard Parity
**Learning:** For custom interactive elements like SVG or DIV-based map regions, `role="button"` and `tabindex="0"` are insufficient on their own. They make elements focusable, but 'click' event listeners do not automatically fire for 'Enter' or 'Space' keys on these non-native buttons. Manual `keydown` listeners must be implemented to ensure accessibility.

**Action:** Always pair click handlers with keydown handlers for custom interactive elements, and ensure a high-contrast `:focus-visible` state is defined to guide keyboard users across complex visual layouts.

## 2025-05-15 - Decoupling UI State from Event Objects
**Learning:** Relying on `event.target` for UI state changes (like adding 'active' classes to buttons) is brittle, especially when the same function can be triggered via different interaction types (click vs. keyboard) or programmatically.

**Action:** Manage UI state using explicit function parameters or data models rather than the `event` object. This ensures consistent behavior and makes the code more robust for automated testing and diverse input methods.
