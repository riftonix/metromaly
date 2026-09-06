## Why

The metro map data is not yet interactive, so a player cannot select a squad or move it between connected stations. A minimal movement slice is needed to verify station interaction, connection costs, action points, station closures, and turn reset behavior before broader gameplay systems are introduced.

## What Changes

- Add a map-space squad marker that can be selected independently from station markers.
- Add clickable station targets and move the selected squad only through a declared direct connection.
- Give every squad one action point, deducting the declared connection cost after a successful move.
- Add mutable `closed_for_entry_station_ids` state that rejects movement into listed stations while allowing squads already there to leave.
- Add an `End Turn` control that restores every squad in the squad collection to one action point.
- Render one initial squad while structuring movement and turn reset around multiple squads.
- Add validation and focused tests for squad records, station references, action points, legal movement, closures, and all-squad turn reset.

## Capabilities

### New Capabilities

- `squad-movement`: Select squads, move them over the metro graph subject to costs and station-entry closures, and restore action points at turn end.

### Modified Capabilities

None.

## Impact

- The metro map scene gains map-space interaction nodes and fixed screen-space turn controls.
- New runtime squad and turn state consumes the station and connection contracts from `MetroMapData`.
- Input handling must distinguish squad selection from station destination clicks under `Camera2D`.
- Automated validation and focused tests gain squad movement and turn-reset coverage.
- No movement animation, pathfinding across multiple edges, enemy interaction, combat, multiplayer turn order, persistence, or squad creation UI is introduced.
