## Why

The initial squad movement interface exposes the required controls but does not clearly distinguish squad availability, selection, movement destinations, or spent action points. Players need to understand what can be selected, where a selected squad can move, why a move is unavailable, and how to end the turn without relying on text labels.

## What Changes

- Give squad markers a silhouette that is visually distinct from station targets.
- Represent unselected, selected-and-mobile, spent, and selected-but-unable-to-move states consistently.
- Display the squad's remaining action point on or immediately around its marker.
- Highlight valid direct destinations after selecting a squad and distinguish free and paid movement.
- Avoid presenting unavailable destinations as actionable.
- Replace the text-facing turn control with an icon-only circular arrow surrounding a small forward triangle.
- Preserve an `End Turn` tooltip, focus indication, and clear hover, pressed, and disabled states.
- Keep squad markers and the turn control as reusable scenes with visual state owned by their respective presentation components.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `squad-movement`: Clarify the visible states and affordances for squad selection, movement availability, action-point cost, and ending the turn.

## Impact

- Squad marker and station target presentation under `apps/client/metro_map/` gains explicit visual state APIs.
- The metro map interaction layer derives destination indicators from the existing movement rules without changing movement legality.
- The screen-space turn control gains an icon-only visual contract and accessibility states.
- Focused scene tests gain coverage for the four squad states, destination indicators, movement cost presentation, and turn-control interaction states.
