## Why

The project cannot implement reliable movement rules until the metro map has an authoritative runtime graph instead of presentation-only SVG geometry and research data. Development also needs a documented `godot` console command so the graph can be validated consistently without depending on launching the Steam client or editor UI.

## What Changes

- Make the Steam-installed Godot 4.7 executable available through the `godot` command in the developer shell and document the environment setup and verification command.
- Restructure the metro map scene as a `Node2D` world viewed through `Camera2D` while retaining the existing SVG map appearance.
- Add desktop camera movement with keyboard arrow keys and bounded zoom with the mouse wheel.
- Initialize and constrain the camera so the map starts framed correctly and cannot be moved entirely outside the viewport.
- Add an expanded line dictionary for the Circle Line and every line that intersects it, including stable identifiers, display names, colors, and playable status.
- Add runtime station records for all Circle Line stations and every directly connected transfer station on intersecting lines.
- Add a flat list of bidirectional connections, declared once per pair, with movement costs that distinguish paid travel between neighboring Circle Line stations from free transfers inside station complexes.
- Add validation that rejects missing references, self-connections, invalid costs, duplicate undirected connections, malformed line assignments, incomplete Circle Line topology, and invalid transfer costs.
- Add automated validation tests and a console command that can validate the map data independently of the metro map UI.

## Capabilities

### New Capabilities

- `godot-cli-environment`: Provide and verify a stable console command for the project's Steam-installed Godot version.
- `metro-map-camera`: Provide bounded desktop navigation of the metro map through `Camera2D`.
- `metro-network-data`: Define and validate the playable Circle Line graph, its stations, intersecting lines, and transfer connections.

### Modified Capabilities

None.

## Impact

- Developer shell setup and project documentation for invoking Godot from the console.
- The metro map scene hierarchy, rendering ownership, input actions, and camera behavior.
- New runtime data and validation code under the executable Godot project rather than `docs/` research materials.
- The future metro map and movement rules receive stable station, line, and connection identifiers.
- No station interaction, mouse-drag navigation, touch input, squad movement, turn handling, or playable travel along intersecting branches is introduced by this change.
