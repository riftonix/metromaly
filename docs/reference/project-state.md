# Project State

Metromaly is currently an early interface vertical slice.

## Implemented

- Full-screen main menu with the project title.
- Responsive main menu background that fills the available area.
- `Start game` and `Exit` actions.
- Initial focus on the start button for keyboard or controller navigation.
- Transition from the menu to the metro map screen.
- Centered SVG map rendering that preserves its aspect ratio.
- Two test station labels: `VDNH` and `Alexeevskaya`.
- A minimal headless server entry point.

## Not Implemented

- Gameplay loop and map interaction.
- Station selection and state.
- Loading station data into the executable project.
- Settings, saved games, and game continuation.
- Returning from the map to the main menu.
- Final visual design for the menu and map.

The client and server currently share one Godot project. Networking, sessions, persistence, and shared gameplay rules have not been implemented.
