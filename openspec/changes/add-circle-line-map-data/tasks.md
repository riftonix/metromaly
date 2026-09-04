## 1. Godot Console Environment

- [x] 1.1 Locate the Steam-installed Godot 4.7 executable and record the resolved executable path, verifying it directly with its `--version` output
- [x] 1.2 Expose the executable as `godot` through the appropriate user shell startup configuration, then verify `godot --version` from a newly started interactive shell
- [x] 1.3 Document the Steam installation discovery, shell setup, and version verification steps in the existing project documentation, and verify all documented commands and paths match the configured environment

## 2. Desktop Map Camera

- [x] 2.1 Restructure the metro map scene into a `Node2D` map world with an active `Camera2D`, preserving the current SVG appearance and verifying the map opens from the main menu without scene or rendering errors
- [ ] 2.2 Add named camera movement actions bound to the keyboard arrow keys and implement frame-rate-independent movement, verifying all four directions work at the supported zoom levels
- [ ] 2.3 Add uniform mouse-wheel zoom with configured minimum and maximum values, verifying repeated wheel input cannot exceed either limit
- [ ] 2.4 Calculate the initial camera framing and clamp camera position against the `1280 x 1500` map bounds after movement, zoom, and viewport resize, verifying the map cannot be moved fully outside the viewport and smaller dimensions remain centered

## 3. Circle Line Source Data

- [ ] 3.1 Cross-reference the SVG, existing station research, and a current authoritative metro source to establish the 12 Circle Line station IDs, order, transfer destinations, intersecting lines, display names, colors, and map coordinates; verify every selected station visually against the SVG
- [ ] 3.2 Add the runtime `LINES` dictionary for the Circle Line and all directly intersecting lines, and verify every line has a stable ID, Russian display name, color, and correct playable flag
- [ ] 3.3 Add the runtime `STATIONS` dictionary for all Circle Line nodes and their direct line-specific transfer destinations, and verify every station references a defined line and uses an SVG-aligned position
- [ ] 3.4 Add each bidirectional Circle Line and transfer connection exactly once with cost `1` for neighboring Circle Line stations and cost `0` for transfers, and verify no paid connection extends along a non-playable branch

## 4. Graph Access and Validation

- [ ] 4.1 Implement undirected direct-connection lookup and verify both endpoint orders return the same cost while unrelated stations return no connection
- [ ] 4.2 Implement structural validation for record shape, line and station references, self-connections, allowed costs, duplicate undirected pairs, and transfer line membership; verify each invalid fixture produces an actionable diagnostic
- [ ] 4.3 Implement Circle Line topology validation for station count, paid degree, connectivity, and closure; verify missing, extra, and disconnected paid-edge fixtures fail
- [ ] 4.4 Add a headless console validation entry point that evaluates the committed dataset, prints concise diagnostics, and verify it exits with code `0` for valid data and non-zero for an invalid fixture

## 5. Automated Tests and Documentation

- [ ] 5.1 Add a lightweight Godot test harness or self-contained test runner for graph lookup and validation, and verify focused tests cover valid data, reverse lookup, missing references, duplicate reverse edges, invalid costs, invalid transfers, and broken Circle Line topology
- [ ] 5.2 Run the focused console tests and committed-data validator through `godot`, recording the exact successful commands and concise results
- [ ] 5.3 Update runtime data and architecture documentation to describe the `Camera2D` scene boundary and the line, station, and single-declaration connection contracts, and verify it does not claim that mouse dragging, touch input, intersecting branches, or movement gameplay are implemented
