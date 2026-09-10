## ADDED Requirements

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
