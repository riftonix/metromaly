# Project Configuration

The main configuration is stored in `project.godot`.

| Setting | Value |
| --- | --- |
| Application name | `metromaly` |
| Godot feature version | `4.7` |
| Startup scene | `apps/client/main_menu/main_menu.tscn` |
| Stretch mode | `canvas_items` |
| Stretch aspect | `expand` |
| Rendering method | `gl_compatibility` |
| Mobile rendering method | `gl_compatibility` |
| 3D physics engine | `Jolt Physics` |

The stretch settings allow full-screen `Control` scenes to occupy the available area. The menu and map scenes also use full anchors for width and height.

## OpenSpec

Change planning is stored in `openspec/` and uses the `spec-driven` schema. OpenSpec artifacts are written in English. The main menu specification is located at `openspec/specs/main-menu/spec.md`.
