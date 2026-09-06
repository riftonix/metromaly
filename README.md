# Metromaly

Turn-based 2D strategy in the Moscow Metro. Stations are nodes, railway
sections are connections. Capture and develop stations, manage the faction
economy, recruit units, and assemble squads to expand your territory.
Multiplayer support is planned.

## Architecture

The repository is a single Godot 4 project divided into runtime apps with a
shared core:

```text
apps/
├── client/   # Godot client: presentation, input, and map
└── server/   # Headless authoritative server

core/          # Shared domain rules, simulation, and game data
tests/         # Tests for the client, server, and core
docs/          # Documentation (Diataxis)
openspec/      # Spec-driven change planning
```

Dependency rule: both apps may use `core/`; `core/` must not depend on either
app, and the apps must not import each other.

## Running

Prerequisites: [Godot 4.7](https://godotengine.org).

Client:

```bash
godot --path .
```

Server:

```bash
godot --headless --path . apps/server/server_main.tscn
```

Verify committed data and run all focused tests:

```bash
make verify
```

## Documentation

Project documentation is organized with the [Diataxis](https://diataxis.fr)
framework and lives in [`docs/`](docs/README.md):

- [Tutorials](docs/tutorials/README.md) - first project launch
- [How-to guides](docs/how-to/README.md) - menu and map customization
- [Reference](docs/reference/README.md) - resources, unit leveling, and buildings
- [Explanation](docs/explanation/README.md) - game concept and architecture
