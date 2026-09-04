## Context

The project uses Godot 4.7 and does not yet have an assigned main scene. The `entities/ui/main_menu/main_menu.tscn` scene already exists as a full-screen `Control` containing a `CenterContainer`, a `VBoxContainer`, a title, and the `StartButton` and `ExitButton` nodes. The behavior script and map scene do not exist yet.

## Goals / Non-Goals

**Goals:**

- Keep the scene and its script together in `entities/ui/main_menu/`.
- Implement button behavior through Godot signals.
- Support mouse, keyboard, and controller menu interaction.
- Keep the map transition simple and replaceable as the project evolves.

**Non-Goals:**

- Final menu artwork, music, or animations.
- Settings, continuing a saved game, or exit confirmation.
- Implementation of the metro map or gameplay logic.

## Decisions

### Use regular Button nodes inside VBoxContainer

Both actions must remain visible without an additional click, so the scene uses separate `Button` nodes instead of a drop-down `MenuButton`. The `VBoxContainer` provides vertical layout and consistent spacing.

### Connect signals in the menu script

The `main_menu.gd` script connects both buttons' `pressed` signals in `_ready()`. This keeps menu behavior in one readable file instead of hiding the connections only in the serialized scene. Connecting signals through the Node dock remains a valid alternative but is less apparent during code review.

### Reference buttons through unique names

The `StartButton` and `ExitButton` nodes receive unique-name status and are referenced as `%StartButton` and `%ExitButton`. Compared with full node paths, this reduces the script's dependency on intermediate containers.

### Use standard scene switching

The start-game action calls `SceneTree.change_scene_to_file()` with the map scene path. A separate screen manager is unnecessary for the first vertical slice. It can be introduced later if transitions, loading, or persistent cross-scene state require it.

### Make the menu the project main scene

`project.godot` must reference `main_menu.tscn` through `run/main_scene` so a normal project run always starts at the menu.

## Risks / Trade-offs

- [The map scene does not exist yet] -> Create a minimal placeholder at the selected stable path before connecting the transition.
- [The hard-coded map path may change] -> Keep the path in the menu handler only and update it when the map structure is finalized.
- [Exit behavior can differ on mobile platforms] -> Use the standard `SceneTree.quit()` for this stage and address mobile navigation separately when preparing the Android build.
