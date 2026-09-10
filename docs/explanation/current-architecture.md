# Current Vertical Slice Architecture

The repository is one Godot project divided into client and server components. The implemented client flow moves from the main menu into an interactive metro map, while the server currently provides only a headless entry point.

## Repository Boundaries

- `apps/client/` owns presentation, input, and client networking.
- `apps/server/` owns the headless process, authoritative sessions, networking, and persistence.
- `core/` is reserved for shared domain rules, simulation, contracts, and runtime data.
- `tests/` mirrors the client, server, and core boundaries.

Both runtime components may depend on `core/`. `core/` must not depend on either component, and the client and server must not import one another directly.

## Application Flow

`project.godot` sets `apps/client/main_menu/main_menu.tscn` as the startup scene. After loading, `main_menu.gd` connects both button signals and gives focus to the start button.

When `Start game` is activated, the menu calls `SceneTree.change_scene_to_file()` and replaces itself with the map scene. There is currently no separate screen router, global state, or loading layer. When `Exit` is activated, the application calls `SceneTree.quit()`.

## Scene Responsibilities

The main menu is responsible only for application entry:

- Displays the available actions.
- Handles input through standard `Button` nodes.
- Changes the scene or terminates the process.

The map screen owns presentation, interaction orchestration, and desktop camera navigation:

- Draws the SVG, station hit targets, squad markers, and test labels in map-space coordinates under `MapWorld`.
- Uses `Camera2D` for arrow-key movement, left-button pointer dragging, and mouse-wheel zoom.
- Frames the map initially and clamps movement to its bounds.
- Selects squads by stable ID and delegates destination requests to the core movement controller.
- Keeps the `End Turn` control in a screen-space `CanvasLayer`, outside camera transforms.

This separation keeps the small vertical slice simple. The connection between screens is currently represented by one string path in the menu handler.

## Map Camera

The map uses a `1280 x 1500` world-space reference area. The initial uniform camera zoom fills the viewport while preserving the SVG aspect ratio. Camera position is clamped after movement, zoom, and viewport resize; an axis remains centered when its visible world area is larger than the map extent.

## Metro Map Data

`core/metro_map/metro_map_data.gd` is the authoritative static catalog for lines, line-specific station nodes, and direct connections. Each undirected connection is declared once as `{stations, cost}`. Cost `1` joins neighboring Circle Line stations, while cost `0` joins direct transfer nodes on different lines.

`core/metro_map/metro_graph.gd` provides order-independent direct-cost lookup. `core/metro_map/metro_map_validator.gd` checks record structure, references, duplicate pairs, transfer semantics, and the closed 12-station Circle Line topology without loading the map scene.

## Squad Movement

`core/squad/squad_state.gd` owns the mutable squad collection. Squads are stored in a dictionary keyed by stable squad ID; each squad has a current `station_id` and either zero or one `action_points`. The initial session renders one squad at `park_kultury_koltsevaya`, while movement and turn reset operate on the complete collection and support additional independent squads. Squad validation is isolated in `core/squad/squad_validator.gd`.

`core/metro_map/metro_map_session_state.gd` owns `closed_for_entry_station_ids` as mutable map state separate from static topology. A listed station rejects incoming movement but does not prevent a squad already there from leaving. Removing the station ID restores entry. Closure validation remains under the map boundary in `core/metro_map/metro_map_session_validator.gd`.

`SquadMovementController` checks the requested destination, direct connection, closure state, and connection cost before changing any squad data. Its non-mutating `list_destinations()` query derives every currently legal direct destination and its cost from the same rules. A successful paid move consumes one action point, while a zero-cost transfer preserves it. A rejected move changes neither the station nor action points. `SquadTurnController` restores every squad to exactly one action point.

The map creates one `StationTarget` for every station catalog entry and positions it from `MetroMapData.STATIONS`. Selecting a squad refreshes `destination_guidance` from the core query and applies neutral, free-destination, or paid-destination presentation to each target. The map recomputes this guidance after successful movement, closure changes, and turn end so stale destinations do not remain highlighted.

Squad markers are reusable entity scenes under `apps/client/squad/` and are placed at the authoritative station position by the map. Their shield silhouette distinguishes them from station targets. Four presentation states combine selected or unselected state with mobile or spent state, and the marker directly displays whether zero or one action point remains. Marker position and action-point presentation are refreshed from squad state after movement and turn end.

The icon-only `End Turn` control is anchored to the lower-right viewport corner and is not transformed by map movement or zoom. Its circular-arrow presentation supports default, hover, pressed, keyboard-focus, and disabled states, and it exposes an `End Turn` tooltip.

Pointer input distinguishes clicks from camera dragging with an eight-pixel threshold. Squad and station activation occurs on button release and is suppressed after a drag, so the player can start dragging from map features without accidentally selecting or moving a squad.

## Runtime Boundary

The client reads its menu scene, local background, map scene, and local SVG map from `apps/client/`. Shared metro map data and deterministic gameplay rules live under `core/`. The server starts independently with:

```bash
godot --headless --path . apps/server/server_main.tscn
```

Squad state currently belongs to the local map session and is not shared with the server or persisted. Touch input is not implemented.
