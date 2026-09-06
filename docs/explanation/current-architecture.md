# Current Vertical Slice Architecture

The repository is one Godot project divided into client and server components. The implemented client flow is a linear transition between two independent scenes, while the server currently provides only a headless entry point.

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

The map screen owns presentation and desktop camera navigation:

- Draws the SVG and test labels in map-space coordinates under `MapWorld`.
- Uses `Camera2D` for arrow-key movement and mouse-wheel zoom.
- Frames the map initially and clamps movement to its bounds.
- Draws test labels in the same coordinate system.

This separation keeps the small vertical slice simple. The connection between screens is currently represented by one string path in the menu handler.

## Map Camera

The map uses a `1280 x 1500` world-space reference area. The initial uniform camera zoom fills the viewport while preserving the SVG aspect ratio. Camera position is clamped after movement, zoom, and viewport resize; an axis remains centered when its visible world area is larger than the map extent.

## Metro Map Data

`core/metro_map/metro_map_data.gd` is the authoritative static catalog for lines, line-specific station nodes, and direct connections. Each undirected connection is declared once as `{stations, cost}`. Cost `1` joins neighboring Circle Line stations, while cost `0` joins direct transfer nodes on different lines.

`core/metro_map/metro_graph.gd` provides order-independent direct-cost lookup. `core/metro_map/metro_map_validator.gd` checks record structure, references, duplicate pairs, transfer semantics, and the closed 12-station Circle Line topology without loading the map scene.

## Runtime Boundary

The client reads its menu scene, local background, map scene, and local SVG map from `apps/client/`. Shared metro map data and deterministic validation live under `core/metro_map/`. The server starts independently with:

```bash
godot --headless --path . apps/server/server_main.tscn
```

No mutable gameplay state is shared between the components yet. Station selection, squad movement, mouse dragging, and touch input are not implemented.
