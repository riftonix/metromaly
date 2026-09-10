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
