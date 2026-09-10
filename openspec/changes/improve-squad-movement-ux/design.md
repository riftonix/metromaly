## Context

The movement slice represents station targets and squad markers as map-space `Area2D` nodes and places the end-turn control in a screen-space `CanvasLayer`. Movement legality and cost already come from the core movement controller. The current squad marker exposes only selected and unselected colors, while the icon-only turn control has pointer states but no keyboard-focus or disabled presentation.

The supplied visual reference uses high-contrast light glyphs, dark inset surfaces, warm metallic borders, and strong state changes. The implementation should adopt those visual principles without importing or copying source artwork.

## Goals / Non-Goals

**Goals:**

- Derive every visual movement state from authoritative squad and movement data.
- Keep reusable marker and turn-control scenes independent from map orchestration.
- Make availability understandable through shape, value, and contrast rather than color alone.
- Preserve map readability at every supported camera zoom.

**Non-Goals:**

- Replacing the metro map artwork or defining the final game-wide theme.
- Movement animation, route previews across multiple edges, sound effects, or tutorial overlays.
- Changing movement costs, action-point rules, station closure semantics, or turn progression.
- Adding touch-specific gestures beyond usable control and target sizes.

## Architecture and Component Boundaries

### Architecture Overview

The map interaction layer computes a presentation snapshot for each squad marker and station target whenever selection, movement, closure state, or turn state changes. Presentation scenes render that snapshot but do not decide movement legality.

### Component Responsibilities

- The map scene owns the selected squad ID and refreshes all movement affordances after relevant state changes.
- The movement controller remains the source of truth for whether a requested move succeeds.
- A query function derives directly connected destination costs and filters destinations using the same station, closure, and action-point constraints as movement.
- The squad marker scene under `apps/client/squad/` renders selection, mobility, and action-point state.
- The station target scene renders destination availability and cost without replacing its input role.
- The end-turn scene owns icon drawing and local control states, then emits activation without mutating turn state.

### Component Boundaries

Visual scenes receive explicit state and do not read the global session directly. The squad marker remains in the client squad boundary, while station targets and closure presentation remain in the metro map boundary. Core query logic does not depend on client nodes, colors, drawing primitives, or camera state.

## Component Changes

### Squad Marker Scene

Replace the station-like circular token with a compact badge silhouette and a recognizable squad glyph. Add an action-point pip and independent selected and spent treatments. Selection uses a strong outline or halo; spent state reduces saturation and changes the AP pip, rather than relying on opacity alone.

### Station Target Scene

Add neutral, free, paid, and unavailable presentation states. Only currently legal destinations receive actionable emphasis. Free and paid destinations use different interior marks so cost remains distinguishable without color.

### Metro Map Scene

Refresh marker and destination presentation after squad selection, successful movement, closure changes, and turn end. Clear destination guidance when no squad is selected. Do not issue speculative mutations while computing guidance.

### End-Turn Scene

Keep the control in its existing right-bottom screen-space container. Draw a circular arrow around a centered forward triangle using a high-contrast light glyph, dark inset background, and warm border. Add keyboard activation, focus drawing, disabled input suppression, pointer capture, and tooltip behavior within the scene.

## Interfaces

### User Interface

The four squad states combine three channels: badge treatment, selection outline, and AP pip. Destination costs combine color and symbol. The end-turn icon remains visible without text but exposes `End Turn` through its tooltip and accessibility metadata.

### Internal Interfaces

Squad marker presentation accepts `selected: bool` and `action_points: int`. Station targets accept a destination state and optional cost. The destination query returns station IDs with costs for legal direct movement and does not mutate the session.

## Error Handling

### Logging and Diagnostics

Unknown squad or station references clear affected guidance and use the existing concise diagnostics policy. Expected unavailable destinations do not produce logs.

## Decisions

### Decision: Derive guidance from core movement constraints

Destination guidance will use a non-mutating core query aligned with movement validation. Reimplementing eligibility only in the scene was rejected because UI guidance could diverge from actual movement behavior.

### Decision: Encode state with more than color

Selection, AP availability, and destination cost will each include a shape or mark difference. Color-only states were rejected because they are less accessible and can disappear against the detailed map.

### Decision: Keep the end-turn glyph procedural

The circular arrow and triangle will remain vector-like Godot drawing primitives so they scale cleanly and do not add a derivative asset from the supplied reference. A raster crop was rejected because it would couple the control to an external sprite sheet and resolution.

## Risks / Trade-offs

- [Destination highlights add clutter to a dense map] -> Render guidance only while a squad is selected and keep unavailable stations neutral.
- [Free movement remains available at zero action points] -> Show free destinations according to the domain rule rather than treating zero AP as globally immobile.
- [Procedural icons can appear too clean beside textured artwork] -> Use layered dark, light, and warm-border shapes while preserving crisp scaling.
- [Small map markers become hard to read at minimum zoom] -> Verify state distinctions at minimum, initial, and maximum supported zoom and adjust screen-readable outlines without changing station coordinates.
