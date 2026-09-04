# First Run

This tutorial covers the complete user flow currently available in Metromaly: opening the main menu, moving to the metro map, and exiting the application.

## Prerequisites

- Godot Engine 4.7.
- A local copy of the project.

If Godot was installed through Steam in the default user directory, its executable is located at:

```text
~/.local/share/Steam/steamapps/common/Godot Engine/godot.x11.opt.tools.64
```

To make the `godot` command available in the terminal, create a user-level symbolic link and add `~/.local/bin` to `PATH`:

```bash
mkdir -p "$HOME/.local/bin"
ln -sfn "$HOME/.local/share/Steam/steamapps/common/Godot Engine/godot.x11.opt.tools.64" "$HOME/.local/bin/godot"
printf '\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$HOME/.bashrc"
```

Start a new shell and verify the installed version:

```bash
godot --version
```

The project requires version `4.7.x`.

## Open the Project

1. Start Godot Project Manager.
2. Import `project.godot` from the project root.
3. Open the imported project.

## Run the Application

Select **Run Project** or press `F6`. Godot opens the startup scene at `apps/client/main_menu/main_menu.tscn`.

The screen displays the `Metromaly` title and the `Start game` and `Exit` buttons. Input focus starts on `Start game`, so you can activate it with the confirm action without using a mouse.

## Open the Map

Activate `Start game`. The application switches to `apps/client/metro_map/metro_map.tscn`.

The map fits within the available window area, preserves its original aspect ratio, and remains centered when the window is resized. The current implementation also draws the test labels `VDNH` and `Alexeevskaya`.

## Verify Exit

Restart the project to return to the main menu, then activate `Exit`. The application process terminates.

This completes the available user flow for the current vertical slice.
