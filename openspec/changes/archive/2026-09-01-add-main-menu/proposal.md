## Why

The project needs its first user-facing entry point, from which the player can start a game or close the application. The main menu also establishes the entry path for the future metro map scene.

## What Changes

- Add a full-screen main menu scene with the project title.
- Display two permanently visible buttons: `Start game` and `Exit`.
- Give initial focus to the start button when the menu opens.
- Open the metro map scene when `Start game` is activated.
- Close the application when `Exit` is activated.
- Make the main menu the project's startup scene.

## Capabilities

### New Capabilities

- `main-menu`: Display the main menu and handle the start-game and exit actions.

### Modified Capabilities

None.

## Impact

- The `entities/ui/main_menu/main_menu.tscn` scene.
- A new menu behavior script stored beside the scene.
- Startup scene configuration in `project.godot`.
- A transition to the future metro map scene, whose path must be stable before the button is connected.
