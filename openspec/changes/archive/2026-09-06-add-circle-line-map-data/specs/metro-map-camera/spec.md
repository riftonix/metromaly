## Purpose

Allow desktop players to inspect the metro map at useful scales and positions through bounded, predictable camera controls.

## ADDED Requirements

### Requirement: Camera-based map presentation
The metro map SHALL be presented as a two-dimensional world viewed through an active camera, while preserving the existing map artwork, proportions, and transition from the main menu.

#### Scenario: Player opens the metro map
- **WHEN** the player activates `Start game` from the main menu
- **THEN** the metro map appears through the active camera without distortion or missing artwork

### Requirement: Keyboard camera movement
The map camera SHALL move continuously in four directions through the keyboard arrow keys, with movement independent of frame rate.

#### Scenario: Player holds an arrow key
- **WHEN** the player holds one of the keyboard arrow keys while the map is open
- **THEN** the camera moves continuously in the corresponding direction

#### Scenario: Player releases an arrow key
- **WHEN** the player releases all camera movement keys
- **THEN** camera movement stops

### Requirement: Mouse-wheel zoom
The map camera SHALL support uniform zoom in and zoom out through the mouse wheel and SHALL constrain zoom to configured minimum and maximum values.

#### Scenario: Player zooms in
- **WHEN** the player scrolls the mouse wheel upward before the maximum zoom is reached
- **THEN** the map is displayed at a larger scale

#### Scenario: Player zooms out
- **WHEN** the player scrolls the mouse wheel downward before the minimum zoom is reached
- **THEN** the map is displayed at a smaller scale

#### Scenario: Player reaches a zoom limit
- **WHEN** the player continues scrolling beyond a configured zoom limit
- **THEN** the camera remains at that limit

### Requirement: Initial framing and camera bounds
The camera SHALL initially frame the complete map while preserving its aspect ratio and SHALL constrain its position after movement, zoom, and viewport resizing so the map cannot be moved entirely outside the visible viewport.

#### Scenario: Map opens
- **WHEN** the map scene finishes loading
- **THEN** the complete map is framed correctly for the current viewport

#### Scenario: Player moves toward a map edge
- **WHEN** camera movement reaches the allowed boundary for the current viewport and zoom
- **THEN** further movement does not move the map entirely outside the viewport

#### Scenario: Viewport size changes
- **WHEN** the viewport size changes while the map is open
- **THEN** camera bounds and framing constraints are recalculated for the new viewport
