## Purpose

Provide contributors with a stable console command for running the project with its required Godot version and for executing project validation commands.

## ADDED Requirements

### Requirement: Godot console command
The development environment SHALL expose the Steam-installed Godot 4.7 executable through the `godot` command in a newly started interactive shell.

#### Scenario: Developer verifies the installation
- **WHEN** a developer starts a shell after completing the documented environment setup and runs `godot --version`
- **THEN** the command succeeds and reports Godot 4.7

### Requirement: Reproducible environment setup
The project documentation SHALL state the executable location used by the Steam installation, the shell configuration needed to expose `godot`, and the command used to verify the setup.

#### Scenario: Developer configures a new checkout
- **WHEN** a developer follows the documented setup with Godot 4.7 installed through Steam
- **THEN** the developer can invoke the project-compatible editor from the console without opening Steam manually
