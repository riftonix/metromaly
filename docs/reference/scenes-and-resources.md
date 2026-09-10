# Scenes and Resources

## Main Menu

| Path | Purpose |
| --- | --- |
| `apps/client/main_menu/main_menu.tscn` | Full-screen startup scene with a centered vertical menu. |
| `apps/client/main_menu/main_menu.gd` | Signal connections, initial focus, map transition, and exit handling. |
| `apps/client/assets/main_menu/background.png` | Menu background scaled while preserving its aspect ratio. |

Unique interface element names:

| Name | Type | Action |
| --- | --- | --- |
| `StartButton` | `Button` | Opens the metro map scene. |
| `ExitButton` | `Button` | Terminates the `SceneTree`. |

## Metro Map

| Path | Purpose |
| --- | --- |
| `apps/client/metro_map/metro_map.tscn` | Interactive map world, camera, and lower-right screen-space HUD. |
| `apps/client/metro_map/metro_map.gd` | Draws the map, controls the camera, creates interaction nodes, and coordinates squad selection and movement. |
| `apps/client/metro_map/station_target.gd` | Map-space station hit target that publishes a stable station ID. |
| `apps/client/squad/squad_marker.tscn` | Reusable map-space squad marker scene. |
| `apps/client/squad/squad_marker.gd` | Squad marker identity, selection state, input, and drawing. |
| `apps/client/metro_map/end_turn_button.tscn` | Reusable icon-only end-turn control scene. |
| `apps/client/metro_map/end_turn_button.gd` | End-turn icon drawing and pointer interaction states. |
| `apps/client/assets/metro_map/metro_map.svg` | Map texture with a `1280 x 1500` coordinate system. |

Key `metro_map.gd` constants:

| Constant | Current Value | Purpose |
| --- | --- | --- |
| `BACKGROUND_COLOR` | `#e1b27b` | Screen background color. |
| `TEXT_COLOR` | `Color.BLACK` | Label color. |
| `REFERENCE_SIZE` | `Vector2(1280.0, 1500.0)` | Original map coordinate system. |
| `MAP_TEXTURE` | `res://apps/client/assets/metro_map/metro_map.svg` | Displayed resource. |
| `STATION_LABELS` | Two dictionaries | Test labels and their coordinates. |

## Metro Map Data

| Path | Purpose |
| --- | --- |
| `core/metro_map/metro_map_data.gd` | Static line, station, and single-declaration connection catalogs. |
| `core/metro_map/metro_graph.gd` | Undirected direct-connection cost lookup. |
| `core/metro_map/metro_map_validator.gd` | Structural and Circle Line topology validation. |
| `core/metro_map/validate_metro_map.gd` | Headless committed-data validation entry point. |
| `tests/core/metro_map/metro_map_test.gd` | Self-contained lookup and invalid-fixture tests. |

## Squad Movement

| Path | Purpose |
| --- | --- |
| `core/squad/squad_state.gd` | Mutable squad collection and initial squad state. |
| `core/squad/squad_validator.gd` | Squad structure, station-reference, and action-point validation. |
| `core/metro_map/metro_map_session_state.gd` | Mutable destination-closure map state. |
| `core/metro_map/metro_map_session_validator.gd` | Known and unique closure-station validation. |
| `core/squad_movement/squad_movement_controller.gd` | Atomic direct movement, connection cost, and entry-closure rules. |
| `core/squad_movement/squad_turn_controller.gd` | All-squad action-point reset. |
| `tests/core/squad/squad_test.gd` | Focused squad state and validation tests. |
| `tests/core/metro_map/metro_map_session_test.gd` | Focused map closure state and validation tests. |
| `tests/core/squad_movement/squad_movement_test.gd` | Focused movement, closure interaction, and turn tests. |
| `tests/apps/client/metro_map/metro_map_interaction_test.gd` | Headless map-scene interaction and screen-space HUD tests. |

The initial session contains one rendered squad at `park_kultury_koltsevaya` with one action point. The dictionary-based model and turn controller operate on any number of squads.

Run all validation and focused tests with:

```bash
make verify
```

The command validates committed metro data, runs the metro graph tests, runs squad rule tests, and loads the interactive map scene through its focused headless test.

## Project Materials

The runtime uses scenes and scripts under `apps/client/` and presentation assets under `apps/client/assets/`.

## Server

| Path | Purpose |
| --- | --- |
| `apps/server/server_main.tscn` | Headless server entry scene. |
| `apps/server/server_main.gd` | Minimal server process startup. |
