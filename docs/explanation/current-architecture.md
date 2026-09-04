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

The map screen is responsible only for presentation:

- Fills the background.
- Calculates one scale factor from the available width and height.
- Centers the SVG map.
- Draws test labels in the same coordinate system.

This separation keeps the small vertical slice simple. The connection between screens is currently represented by one string path in the menu handler.

## Map Scaling

The map uses a `1280 x 1500` reference area. For the current `Control` size, the smaller of the width and height scale factors is selected. This keeps the image uncropped, undistorted, and centered. The same transform is applied to labels, keeping their coordinates attached to the image.

## Runtime Boundary

The client reads its menu scene, local background, map scene, and local SVG map from `apps/client/`. The two visible labels are defined directly in `STATION_LABELS`. The server starts independently with:

```bash
godot --headless --path . apps/server/server_main.tscn
```

No gameplay state is shared between the components yet. Future shared runtime data and deterministic rules belong in `core/`.
