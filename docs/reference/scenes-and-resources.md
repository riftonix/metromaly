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
| `apps/client/metro_map/metro_map.tscn` | Map world and camera scene. |
| `apps/client/metro_map/metro_map.gd` | Draws the background, map, and test labels and controls the camera. |
| `apps/client/assets/metro_map/metro_map.svg` | Map texture with a `1280 x 1500` coordinate system. |

Key `metro_map.gd` constants:

| Constant | Current Value | Purpose |
| --- | --- | --- |
| `BACKGROUND_COLOR` | `#e1b27b` | Screen background color. |
| `TEXT_COLOR` | `Color.BLACK` | Label color. |
| `REFERENCE_SIZE` | `Vector2(1280.0, 1500.0)` | Original map coordinate system. |
| `MAP_TEXTURE` | `res://apps/client/assets/metro_map/metro_map.svg` | Displayed resource. |
| `STATION_LABELS` | Two dictionaries | Test labels and their coordinates. |

## Project Materials

The runtime uses scenes and scripts under `apps/client/` and presentation assets under `apps/client/assets/`.

## Server

| Path | Purpose |
| --- | --- |
| `apps/server/server_main.tscn` | Headless server entry scene. |
| `apps/server/server_main.gd` | Minimal server process startup. |
