## 1. Menu Scene

- [x] 1.1 Create `entities/ui/main_menu/main_menu.tscn` with a full-screen root `Control` and verify that the scene exists in the project
- [x] 1.2 Add a centered vertical layout containing the title, `StartButton`, and `ExitButton`, and verify the node text and placement in the scene

## 2. Behavior and Startup

- [x] 2.1 Assign unique names to the buttons, add `main_menu.gd`, connect the `pressed` signals, and verify that the scene loads without errors
- [x] 2.2 Implement the `Exit` action by terminating the scene tree and verify that the button closes the running application
- [x] 2.3 Implement the `Start game` action by switching to an existing minimal map scene and verify that the transition succeeds without a missing-resource error
- [x] 2.4 Make the main menu the startup scene, give initial focus to `StartButton`, and verify project startup and button activation with both mouse and keyboard input
