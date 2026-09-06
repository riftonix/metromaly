## Context

The executable project currently renders `apps/client/assets/metro_map/metro_map.svg` from `apps/client/metro_map/metro_map.tscn` using `Node2D` and `Camera2D`. It does not yet define an authoritative gameplay graph. No automated test framework exists. The required Godot 4.7 installation is currently managed through Steam.

## Goals / Non-Goals

**Goals:**

- Keep the first runtime graph small, readable, and directly usable from GDScript.
- Prevent asymmetric movement data by declaring each bidirectional connection once.
- Preserve enough line metadata to support map presentation and later branch expansion.
- Validate both generic referential integrity and Circle-Line-specific topology from the console.
- Establish a stable `godot` command before adding command-line validation.
- Establish map-space rendering under `Node2D` and bounded desktop navigation through `Camera2D`.

**Non-Goals:**

- Parsing the SVG at runtime.
- Modeling travel along intersecting branches.
- Implementing mouse-drag camera movement, touch gestures, station selection, squads, turns, combat, or persistence.
- Introducing a general-purpose graph library or a complete Moscow Metro dataset.

## Architecture and Component Boundaries

### Architecture Overview

The change restructures the map scene into a map-space `Node2D` world controlled by `Camera2D`, then adds one runtime metro map data source and a separate validator. Future UI and gameplay code read the data source but do not own or infer graph topology. The existing SVG remains presentation artwork.

### Component Responsibilities

- The line catalog owns stable line IDs and presentation metadata.
- The station catalog owns stable station IDs, line membership, English display names, and SVG-space positions.
- The connection catalog owns undirected endpoint pairs and costs.
- The validator owns structural checks and Circle Line invariants.
- A console test or validation entry point reports failures through a non-zero process exit code.
- The map world owns map-space drawing, while `Camera2D` owns viewport position and zoom.
- Named input actions own desktop camera direction bindings so camera code does not depend on hard-coded key codes.

### Component Boundaries

Research inputs under `docs/` can help populate and review the runtime data but remain outside the runtime contract. Game rules may consume connection costs later, but this change does not define turn state or apply movement.

## Component Changes

### Developer Environment

Locate the actual Steam-managed Godot executable and expose it as `godot` through the user's shell startup configuration. Prefer adding the executable directory to `PATH`; use a shell alias or symbolic link only if the Steam layout does not provide a stable directory that can be added safely. Document the detected path and verify the exact major and minor version. User-specific absolute paths must not be committed as project configuration.

### Metro Map Camera

Replace the map scene's full-screen `Control` ownership of world rendering with a `Node2D` map world and an active `Camera2D`. Keep any future fixed screen UI outside the camera-transformed world. Render the SVG in its native map-space dimensions so station coordinates and camera bounds share the existing `1280 x 1500` reference system.

Define named input actions for left, right, up, and down movement, bound to the corresponding keyboard arrow keys. Apply movement in `_process(delta)` so speed is frame-rate independent. Scale world-space movement speed by inverse zoom so screen-space navigation remains usable across the supported zoom range.

Handle mouse-wheel input by applying a uniform clamped `Camera2D.zoom`. This first version may zoom around the viewport center; cursor-anchored zoom is not required. Set the initial zoom to contain the whole map in the viewport while preserving aspect ratio, then clamp camera position after movement, zoom, and viewport resize. When one map dimension is smaller than the visible world area, center that dimension rather than permitting empty-space movement.

### Metro Map Data

Store the data in executable project code or a Godot-readable resource under `core/metro_map/`. Use dictionaries keyed by stable snake_case IDs for lines and stations, plus an array of connection dictionaries. Each connection contains an unordered `stations` array with exactly two station IDs and a `cost` value:

```gdscript
const LINES := {
    "koltsevaya": {
        "name": "Circle Line",
        "color": Color("#8D5B2D"),
        "playable": true,
    },
}

const STATIONS := {
    "park_kultury_koltsevaya": {
        "name": "Park Kultury",
        "line_id": "koltsevaya",
        "position": Vector2(0, 0),
    },
}

const CONNECTIONS := [
    {
        "stations": ["park_kultury_koltsevaya", "oktyabrskaya_koltsevaya"],
        "cost": 1,
    },
    {
        "stations": ["park_kultury_koltsevaya", "park_kultury_sokolnicheskaya"],
        "cost": 0,
    },
]
```

The position above is illustrative only. Implementation must derive actual coordinates from the existing map assets rather than copying placeholders from this design.

### Validation

Build a canonical undirected key by sorting the two IDs in `stations`. This detects both exact duplicates and repeated records with reversed station order. Generic validation checks shape, references, endpoint identity, line membership, and costs restricted to `0` or `1`. Domain validation then checks that the Circle Line subgraph contains exactly 12 stations, that every one has degree two, that all 12 are reachable, and that every zero-cost edge joins valid transfer endpoints on different lines.

Tests should exercise the validator with small in-memory fixtures as well as the committed dataset. This keeps failure cases deterministic without mutating production data files.

## Data Model

### Entities and Relationships

- A line is identified by a dictionary key and contains `name`, `color`, and `playable`.
- A station is identified by a dictionary key and contains `name`, `line_id`, and `position`.
- A connection contains a `stations` array with exactly two different station IDs and a `cost` of `0` or `1`.
- A station belongs to exactly one line-specific node. Equal display names are allowed across lines.
- A cost-zero connection represents a direct transfer and must join nodes on different lines.
- A cost-one connection in this dataset represents neighboring Circle Line nodes.

### Ownership and Lifecycle

The runtime dataset is version-controlled static content. It has no save-game lifecycle and is loaded read-only. Stable IDs are treated as contracts for future gameplay state, so renaming an ID later requires an explicit migration decision once saved state exists.

### Indexes and Constraints

The dictionaries provide direct lookup by ID. Consumers can build an adjacency lookup once from `CONNECTIONS`; the source remains a single unordered declaration per station pair.

## Interfaces

### Command-Line Interface

The environment exposes `godot --version`. The implementation also provides one documented headless project command that validates the committed metro map data and returns exit code `0` on success and a non-zero exit code with concise diagnostics on failure. The exact script path is selected during implementation to match the final file layout.

### Internal Interfaces

Consumers query lines and stations by ID and connection cost by an unordered pair of station IDs. Missing station IDs and unrelated pairs remain distinguishable from valid zero-cost transfers.

## Error Handling

### Error Categories

Validation diagnostics distinguish malformed records, missing references, duplicate connections, invalid costs, invalid transfers, and invalid Circle Line topology.

### Error Propagation and Mapping

The console entry point prints concise, actionable diagnostics containing the offending identifiers and exits unsuccessfully if any error exists. It reports all independently detectable errors in one run rather than stopping at the first malformed record.

## Decisions

### Decision: Declare undirected connections once

Each connection stores its two endpoints in an unordered `stations` field and is interpreted in both directions. This avoids implying direction through `from` and `to` fields and removes the most likely manual-data defect: adding or changing one direction without updating the other. Per-station neighbor dictionaries were rejected because they duplicate every connection.

### Decision: Keep line metadata as an expanded dictionary

Lines are represented explicitly from the start because color, display name, and playable status are already needed, and future branches can extend the same records. A dedicated class hierarchy was rejected as unnecessary for static data at this stage.

### Decision: Represent transfer destinations as line-specific station nodes

Stations with the same public name on different lines receive different stable IDs. This makes a free transfer an observable graph move and avoids inventing special transfer metadata that gameplay cannot traverse. Physical station-complex entities are deferred until another rule requires them.

### Decision: Mark intersecting branches non-playable

All direct transfer destinations and their lines are represented, but only the Circle Line has paid neighbor connections. This preserves complete transfer information without implying that unmodeled branches can be traversed.

### Decision: Keep validation independent of map rendering

The graph validator operates on data without loading the metro map scene. This supports fast headless execution and prevents artwork changes from silently redefining gameplay topology.

### Decision: Use Camera2D for desktop map navigation

The map becomes a `Node2D` world viewed through `Camera2D`, making position and zoom explicit engine concepts and providing a direct foundation for future map-space station markers. Extending the current `Control` draw transform was rejected because it would require custom camera and inverse-coordinate behavior as interaction grows.

### Decision: Start with keyboard and wheel input only

The first camera slice supports arrow-key movement and mouse-wheel zoom. Mouse dragging and touch gestures are deferred so scene restructuring, zoom limits, and map bounds can be verified independently before cross-device gesture arbitration is introduced.

## Risks / Trade-offs

- [The SVG and research JSON may disagree on station coordinates or identity] -> Cross-check every committed node against the visible SVG and an authoritative current metro source, then review validation output and map placement manually.
- [Steam may install Godot at a machine-specific path] -> Document discovery and shell setup instead of committing one user's absolute path.
- [A degree-two check can accept multiple disconnected cycles] -> Require all 12 Circle Line stations to be reachable from one selected station.
- [Line colors and graph topology can become outdated] -> Keep source references with implementation documentation and require validation plus visual review when data changes.
- [Line-specific transfer nodes add records that cannot travel farther] -> Mark their lines non-playable and omit paid branch connections until branch scope is approved.
- [Camera limits depend on both viewport size and zoom] -> Recalculate limits after every zoom and viewport-size change, centering an axis when the visible area exceeds the map extent.
- [A large zoom range can expose rasterization artifacts in the imported SVG texture] -> Choose conservative limits and visually verify both endpoints before increasing the maximum zoom.

## Migration Plan

### Rollout

Add the shell setup documentation first, restructure and validate the desktop map camera, then add runtime data, validation, tests, and the headless validation command.

### Backward Compatibility

No runtime consumer or persisted game state currently depends on station identifiers, so this is an additive contract.

### Rollback

Restore the previous map scene hierarchy and rendering script, then remove the new runtime data and validation entry point. Revert only the documented shell setup if the selected Steam executable path proves unsuitable; the existing main menu remains unaffected.
