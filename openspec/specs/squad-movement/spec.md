# Squad Movement Specification

## Purpose

Allow players to select squads on the metro map, move them through valid direct connections, and manage station-entry closures and per-turn action points.

## Requirements

### Requirement: Squad state
The game SHALL represent each squad with a stable identifier, current station identifier, and integer action-point count. The runtime SHALL manage squads as a collection even when the initial game state contains only one squad.

#### Scenario: Initial squad is created
- **WHEN** the metro map initializes the first playable state
- **THEN** one squad exists at a defined station with one action point

#### Scenario: Multiple squads are present
- **WHEN** more than one squad exists in the runtime collection
- **THEN** each squad retains independent station and action-point state

### Requirement: Map selection
The player SHALL be able to select a squad by activating its map marker. A squad marker SHALL be centered on its current station and SHALL have the same diameter as a station marker.

#### Scenario: Player selects a squad
- **WHEN** the player activates a squad marker
- **THEN** that squad becomes the selected squad for the next destination action

#### Scenario: Player selects another squad
- **WHEN** one squad is selected and the player activates another squad marker
- **THEN** the newly activated squad becomes selected without moving either squad

### Requirement: Direct movement
The selected squad SHALL move only to a station connected directly to its current station by the metro map data. Activating the current station, an unrelated station, or a destination without a direct connection SHALL leave squad state unchanged.

#### Scenario: Player selects a connected station
- **GIVEN** a squad is selected and a direct connection exists to the destination
- **WHEN** the player activates the destination station
- **THEN** the squad moves to the destination station subject to action points and station-entry closure

#### Scenario: Player selects an unrelated station
- **GIVEN** a squad is selected and no direct connection exists to the destination
- **WHEN** the player activates the destination station
- **THEN** the squad position, current station, and action points remain unchanged

### Requirement: Movement cost
A successful squad move SHALL deduct the direct connection cost from that squad's action points. The move SHALL be rejected without changing state when the squad has fewer action points than the connection cost.

#### Scenario: Squad uses a paid connection
- **GIVEN** the selected squad has one action point and the direct connection costs one
- **WHEN** the player activates the destination station
- **THEN** the squad moves and its action points become zero

#### Scenario: Squad uses a free transfer
- **GIVEN** a direct transfer costs zero
- **WHEN** the selected squad moves through that transfer
- **THEN** the squad moves without losing an action point

#### Scenario: Squad lacks action points
- **GIVEN** the selected squad has zero action points and the direct connection costs one
- **WHEN** the player activates the destination station
- **THEN** the movement is rejected and squad state remains unchanged

### Requirement: Station entry closure
The game state SHALL maintain `closed_for_entry_station_ids` as an array of unique station identifiers. A squad SHALL NOT enter a listed station, but a squad already at that station SHALL be allowed to leave through an otherwise valid connection. Removing a station identifier from the array SHALL restore incoming movement.

#### Scenario: Squad attempts to enter a closed station
- **GIVEN** the destination station is listed in `closed_for_entry_station_ids`
- **WHEN** the player requests an otherwise valid move into it
- **THEN** the movement is rejected without changing squad state

#### Scenario: Squad leaves a closed station
- **GIVEN** the squad's current station is listed and the destination is not listed
- **WHEN** the player requests an otherwise valid move
- **THEN** the closure does not prevent the squad from leaving

#### Scenario: Station reopens
- **GIVEN** a station identifier is removed from `closed_for_entry_station_ids`
- **WHEN** the player requests an otherwise valid move into that station
- **THEN** the former closure does not prevent movement

### Requirement: End turn
The map SHALL provide an `End Turn` control outside the camera-transformed map world. Activating it SHALL restore every squad in the runtime collection to exactly one action point.

#### Scenario: Player ends the turn with one squad
- **WHEN** the player activates `End Turn`
- **THEN** the squad's action points become one

#### Scenario: Player ends the turn with multiple squads
- **WHEN** the player activates `End Turn` while multiple squads have different action-point values
- **THEN** every squad's action points become one

### Requirement: Squad state validation
Automated validation SHALL reject a squad with a missing or duplicate identifier, an unknown current station, or an action-point value outside zero and one. It SHALL also reject an unknown or duplicate station identifier in `closed_for_entry_station_ids`.

#### Scenario: Invalid squad station
- **WHEN** a squad references a station absent from the metro map data
- **THEN** validation fails and identifies the squad and station identifiers

#### Scenario: Invalid closure entry
- **WHEN** `closed_for_entry_station_ids` contains an unknown or duplicate station identifier
- **THEN** validation fails and identifies the invalid entry

### Requirement: Squad marker visual states
The map SHALL distinguish a squad marker from station markers by shape or iconography and SHALL visually distinguish these four states: unselected with an action point, selected with an action point, unselected without an action point, and selected without an action point. Selection SHALL remain available when the squad has no action points.

#### Scenario: Mobile squad is unselected
- **GIVEN** a squad has one action point
- **WHEN** the squad is not selected
- **THEN** its marker indicates that it is available without presenting destination guidance

#### Scenario: Mobile squad is selected
- **GIVEN** a squad has one action point
- **WHEN** the player selects the squad
- **THEN** its marker displays the selected-and-mobile state

#### Scenario: Spent squad is unselected
- **GIVEN** a squad has zero action points
- **WHEN** the squad is not selected
- **THEN** its marker displays a spent state distinct from an available squad

#### Scenario: Spent squad is selected
- **GIVEN** a squad has zero action points
- **WHEN** the player selects the squad
- **THEN** its marker displays a selected-but-spent state without implying that paid movement is available

### Requirement: Action-point indication
Each squad marker SHALL display whether the squad has zero or one action point without requiring the player to open another screen.

#### Scenario: Action point is available
- **GIVEN** a squad has one action point
- **WHEN** its marker is visible
- **THEN** the marker displays one available action point

#### Scenario: Action point is spent
- **GIVEN** a squad has zero action points
- **WHEN** its marker is visible
- **THEN** the marker displays an empty or spent action-point indication

### Requirement: Destination guidance
Selecting a squad SHALL highlight every directly connected destination that the squad can currently enter. Guidance SHALL distinguish zero-cost destinations from one-action-point destinations and SHALL NOT present unrelated, closed, or unaffordable destinations as available.

#### Scenario: Selected squad has paid and free destinations
- **GIVEN** a selected squad has one action point and has valid direct connections with costs zero and one
- **WHEN** destination guidance is displayed
- **THEN** both destination types are highlighted with visually distinct cost indications

#### Scenario: Selected squad cannot afford a paid destination
- **GIVEN** a selected squad has zero action points and a direct destination costs one
- **WHEN** destination guidance is displayed
- **THEN** the paid destination is not presented as available

#### Scenario: Selected squad has a free destination after spending its action point
- **GIVEN** a selected squad has zero action points and a direct destination costs zero
- **WHEN** destination guidance is displayed
- **THEN** the free destination remains presented as available

#### Scenario: Destination is closed for entry
- **GIVEN** a directly connected destination is closed for entry
- **WHEN** destination guidance is displayed
- **THEN** the destination is not presented as available

### Requirement: Icon-only end-turn control
The screen-space end-turn control SHALL use a circular arrow and SHALL contain no visible text label. It SHALL provide an `End Turn` tooltip and visually distinct default, hover, pressed, keyboard-focus, and disabled states.

#### Scenario: Player identifies the end-turn control
- **WHEN** the end-turn control is displayed
- **THEN** it shows a circular arrow without visible text

#### Scenario: Pointer hovers over the end-turn control
- **WHEN** the pointer rests over the end-turn control
- **THEN** the control displays its hover state and exposes the `End Turn` tooltip

#### Scenario: Keyboard focus reaches the end-turn control
- **WHEN** keyboard or controller navigation focuses the end-turn control
- **THEN** the control displays a focus indicator distinct from hover and default states

#### Scenario: End turn is unavailable
- **WHEN** ending the turn is temporarily unavailable
- **THEN** the control displays a disabled state and does not activate turn end
