## 1. Squad State and Validation

- [x] 1.1 Add a runtime squad collection keyed by stable squad ID with `station_id` and `action_points`, seed one initial squad with one action point, and verify the state supports adding a second independent squad without structural changes
- [x] 1.2 Add mutable `closed_for_entry_station_ids: Array[String]` session state and validation for unique known station IDs, verifying unknown and duplicate closure fixtures fail with actionable diagnostics
- [x] 1.3 Add squad validation for unique IDs, known current stations, and action points restricted to zero or one, verifying each invalid fixture fails without loading the map scene

## 2. Movement Rules

- [x] 2.1 Implement an atomic movement operation using `MetroGraph` direct-connection lookup, verifying connected moves succeed while current-station and unrelated-station requests leave squad state unchanged
- [x] 2.2 Apply connection cost after successful movement, verifying cost-one moves consume the squad's action point, cost-zero transfers do not, and insufficient action points reject movement without partial state changes
- [x] 2.3 Reject movement when only the destination is present in `closed_for_entry_station_ids`, verifying entry is blocked, exit remains allowed, and removing the destination ID restores entry

## 3. Map Interaction

- [x] 3.1 Create map-space station hit targets from `MetroMapData.STATIONS` and verify each target publishes the correct station ID at every supported zoom level
- [x] 3.2 Add a station-sized squad marker for the initial squad and selection by stable squad ID, verifying squad activation takes priority over an overlapping station target and selecting another squad changes selection without movement
- [x] 3.3 Connect destination activation to the movement operation and synchronize the marker from authoritative squad state, verifying valid clicks move the marker and rejected clicks do not change marker position, station ID, or action points

## 4. Turn Control

- [x] 4.1 Add a fixed screen-space `End Turn` button outside `MapWorld` and verify camera movement and zoom do not transform it
- [x] 4.2 Reset every squad in the runtime collection to exactly one action point when `End Turn` is activated, verifying both the initial one-squad state and a multi-squad fixture with different action-point values

## 5. Automated Tests and Documentation

- [x] 5.1 Add focused headless tests for selection-independent movement rules, reverse connection use, invalid destinations, paid movement, free transfers, insufficient action points, closure direction, reopening, squad validation, closure validation, and all-squad turn reset
- [x] 5.2 Run the focused console tests and a headless map-scene load through `godot`, recording the exact successful commands and concise results
- [x] 5.3 Update runtime and architecture documentation for squad state, destination-based closure behavior, station hit targets, and `End Turn`, verifying it states that one squad is initially rendered while the model supports multiple squads
