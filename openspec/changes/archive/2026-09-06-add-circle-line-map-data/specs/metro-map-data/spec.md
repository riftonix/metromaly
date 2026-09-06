## Purpose

Provide an authoritative, validated runtime graph for the Moscow Metro Circle Line and its direct transfers so gameplay can query stations and movement costs without interpreting map artwork.

## ADDED Requirements

### Requirement: Line catalog
The metro map data SHALL define the Circle Line and every metro line that has a direct interchange with a Circle Line station. Each line SHALL have a stable identifier, display name, display color, and a flag indicating whether travel along that line is playable in the current graph.

#### Scenario: Consumer lists intersecting lines
- **WHEN** a consumer reads the line catalog
- **THEN** it receives metadata for the Circle Line and every line referenced by a transfer station

#### Scenario: Consumer distinguishes playable lines
- **WHEN** a consumer reads the line catalog
- **THEN** the Circle Line is marked playable and intersecting lines without modeled branch travel are marked non-playable

### Requirement: Station catalog
The metro map data SHALL define all 12 Circle Line stations and each directly connected transfer station on an intersecting line. Each station SHALL have a stable identifier, English display name, line identifier, and map position aligned with the existing SVG coordinate system.

#### Scenario: Consumer reads a Circle Line station
- **WHEN** a consumer requests a known Circle Line station by its identifier
- **THEN** it receives the station name, Circle Line identifier, and map position

#### Scenario: Consumer reads a transfer destination
- **WHEN** a Circle Line station has a direct interchange with another metro line
- **THEN** the station catalog contains the corresponding line-specific destination referenced by the transfer connection

### Requirement: Bidirectional connection catalog
The metro map data SHALL represent each unordered station pair once as a record containing a `stations` array of exactly two station identifiers and a `cost` of `0` or `1`. Each connection SHALL be traversable in either direction without a reverse declaration.

#### Scenario: Consumer queries a declared connection forward
- **WHEN** a consumer queries the cost from the first endpoint to the second endpoint
- **THEN** it receives the declared movement cost

#### Scenario: Consumer queries a declared connection in reverse
- **WHEN** a consumer queries the cost from the second endpoint to the first endpoint
- **THEN** it receives the same movement cost without a separate reverse record

#### Scenario: Consumer queries unrelated stations
- **WHEN** a consumer queries two stations without a declared connection
- **THEN** the graph reports that no direct move is available

### Requirement: Circle Line topology and movement costs
The graph SHALL form one closed cycle containing each of the 12 Circle Line stations exactly once. Connections between neighboring Circle Line stations SHALL cost one movement point, while direct interchanges between lines in the same station complex SHALL cost zero movement points. The graph SHALL NOT model travel beyond a transfer station along a non-playable intersecting line.

#### Scenario: Travel to a neighboring Circle Line station
- **WHEN** a consumer queries two neighboring Circle Line stations
- **THEN** the graph reports a direct bidirectional connection costing one movement point

#### Scenario: Circle Line closes at the final pair
- **WHEN** a consumer follows the paid Circle Line connections through all 12 stations
- **THEN** the final station has a paid connection back to the first station and every Circle Line station has exactly two paid Circle Line neighbors

#### Scenario: Transfer within a station complex
- **WHEN** a consumer queries a declared transfer between the Circle Line and an intersecting line
- **THEN** the graph reports a direct bidirectional connection costing zero movement points

#### Scenario: Travel along an intersecting branch
- **WHEN** a consumer queries travel from a transfer destination to the next station on its non-playable line
- **THEN** the graph reports that no direct move is available

### Requirement: Metro map data validation
The project SHALL provide an automated console validation that fails when a connection record does not contain exactly `stations` and `cost`, `stations` does not contain exactly two station identifiers, a line or station reference is missing, a station connects to itself, a cost is not `0` or `1`, an unordered station pair is duplicated, a station references an unknown line, a transfer has a non-zero cost, or the Circle Line does not form the required 12-station cycle.

#### Scenario: Valid metro map data
- **WHEN** the validator evaluates the committed Circle Line data
- **THEN** validation succeeds without errors

#### Scenario: Duplicate reverse connection
- **WHEN** the data contains both endpoints of an existing connection in reverse order
- **THEN** validation fails and identifies the duplicate undirected connection

#### Scenario: Invalid connection shape
- **WHEN** a connection does not contain a two-item `stations` array and one `cost` value
- **THEN** validation fails and identifies the malformed connection record

#### Scenario: Invalid topology
- **WHEN** a paid Circle Line connection is missing or references a non-Circle-Line station
- **THEN** validation fails and identifies the topology violation

#### Scenario: Invalid transfer
- **WHEN** a transfer connection has a non-zero movement cost or references an unknown station or line
- **THEN** validation fails and identifies the invalid transfer
