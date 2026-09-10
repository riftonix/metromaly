# Project State

Metromaly is currently an early interface vertical slice.

## Implemented

- Full-screen main menu with the project title.
- Responsive main menu background that fills the available area.
- `Start game` and `Exit` actions.
- Initial focus on the start button for keyboard or controller navigation.
- Transition from the menu to the metro map screen.
- Camera-based SVG map rendering with bounded keyboard movement and mouse-wheel zoom.
- Two test station labels: `VDNH` and `Alexeevskaya`.
- Runtime data for the 12 Circle Line station nodes and their direct transfer nodes.
- Undirected direct-connection lookup and automated structural and topology validation.
- Map-space hit targets generated for every station in the runtime catalog.
- One initially rendered squad backed by a collection that supports multiple independent squads.
- Squad selection and atomic direct movement with zero-or-one connection costs.
- Destination-based station closures that block entry while allowing exit.
- A lower-right screen-space `End Turn` control that restores every squad to one action point.
- Focused headless tests for squad state, movement rules, map interaction, and turn reset.
- A single `make verify` command for committed-data validation and focused tests.
- A minimal headless server entry point.

## Not Implemented

- Broader gameplay beyond squad movement and turn reset.
- Station ownership, construction, combat, and dynamic closure controls.
- Multi-edge pathfinding, movement animation, and squad creation UI.
- Settings, saved games, and game continuation.
- Returning from the map to the main menu.
- Final visual design for the menu and map.

The client and server currently share one Godot project. Networking, server-owned sessions, and persistence have not been implemented; current squad gameplay rules are shared under `core/`, while mutable session state remains local to the map scene.
