## 1. Movement Guidance Query

- [x] 1.1 Add a non-mutating query for legal direct destinations and their costs using the existing connection, closure, and action-point rules, verifying paid, free, unaffordable, closed, current, unrelated, and unknown destinations with focused core tests
- [x] 1.2 Integrate destination-query refreshes with squad selection, successful movement, closure changes, and turn end, verifying stale destination guidance is cleared after each state transition

## 2. Squad Marker States

- [x] 2.1 Redesign the reusable squad marker scene with a squad-specific badge silhouette and glyph distinct from station targets, verifying visual bounds and hit targets remain centered on the authoritative station position at supported zoom levels
- [x] 2.2 Add explicit unselected-mobile, selected-mobile, unselected-spent, and selected-spent presentation states, verifying each state differs through outline, shape, or value rather than color alone
- [x] 2.3 Add a zero-or-one action-point indicator to the marker and synchronize it after movement and turn end, verifying paid movement empties it, free movement preserves it, and turn end restores it

## 3. Destination Presentation

- [x] 3.1 Extend the reusable station target scene with neutral, free-destination, and paid-destination states, verifying free and paid costs remain distinguishable without color
- [x] 3.2 Display guidance only for destinations returned by the core query, verifying unrelated, closed, and unaffordable destinations remain neutral while free destinations remain available at zero action points
- [x] 3.3 Clear or recompute destination states when selection or authoritative state changes, verifying no previously valid station remains highlighted after it becomes invalid

## 4. End-Turn Control

- [x] 4.1 Refine the reusable icon-only end-turn scene to show a circular arrow surrounding a small forward triangle with no visible text, verifying the glyph scales within the existing right-bottom control at supported viewport sizes
- [x] 4.2 Add distinct default, hover, pressed, keyboard-focus, and disabled states plus the `End Turn` tooltip, verifying mouse, keyboard, and controller activation work while disabled activation is suppressed

## 5. Integration and Documentation

- [x] 5.1 Add focused scene tests for all four squad states, AP synchronization, destination cost guidance, stale-guidance clearing, and end-turn control states, verifying the map scene loads headlessly without script errors
- [x] 5.2 Update current architecture and UI reference documentation for squad marker states, destination guidance, and the icon-only end-turn control, verifying document indexes and relative links remain valid
