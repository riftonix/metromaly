# Change the Main Menu

The main menu scene and script are stored in `apps/client/main_menu/`.

The background image is stored at `apps/client/assets/main_menu/background.png`. The `Background` node fills the scene and uses `Keep Aspect Covered`: the image preserves its aspect ratio and fills the screen while excess edges are cropped.

## Change the Text and Layout

Open `apps/client/main_menu/main_menu.tscn` in the Godot editor.

- The title is in the `MainMenu/CenterContainer/VBoxContainer/Title` node.
- The start button is named `StartButton`.
- The exit button is named `ExitButton`.
- `VBoxContainer` controls the spacing between elements.
- `CenterContainer` keeps the content centered in the available area.

Do not disable **Unique Name in Owner** for the buttons. The script accesses them through `%StartButton` and `%ExitButton`.

## Change the Game Scene

Open `apps/client/main_menu/main_menu.gd` and change the value of `METRO_MAP_SCENE` in `_on_start_pressed()`:

```gdscript
const METRO_MAP_SCENE := "res://apps/client/metro_map/metro_map.tscn"
```

The path must point to an existing Godot scene. A scene transition failure is reported through `push_error()`.

## Change the Initial Focus

Currently, `_ready()` calls `start_button.grab_focus()`. To start focus on another element, call `grab_focus()` on the target `Control` after connecting the signals.

## Change the Exit Action

The `_on_exit_pressed()` method calls `get_tree().quit()`. Add confirmation or state persistence before this call if the project introduces such a flow.
