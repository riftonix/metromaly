## Purpose

The main menu provides a clear starting point from which the user can enter the game or close the application.

## ADDED Requirements

### Requirement: Main menu display
The application SHALL display a full-screen main menu at startup with the game title and permanently visible `Start game` and `Exit` actions.

#### Scenario: Application startup
- **WHEN** the user starts the application
- **THEN** the main menu is displayed with a title and two buttons

#### Scenario: Window resizing
- **WHEN** the application window size changes
- **THEN** the menu content remains centered in the available area

### Requirement: Start game
The main menu SHALL allow the user to enter the metro map screen through the `Start game` action.

#### Scenario: User starts a game
- **WHEN** the user activates `Start game`
- **THEN** the application opens the metro map screen

### Requirement: Exit application
The main menu SHALL allow the user to close the application through the `Exit` action.

#### Scenario: User exits the game
- **WHEN** the user activates `Exit`
- **THEN** the application requests termination of the current game process

### Requirement: Initial focus
The main menu SHALL assign input focus to the `Start game` action when the menu opens.

#### Scenario: Pointer-free navigation
- **WHEN** the main menu finishes loading
- **THEN** the user can activate `Start game` with a keyboard or controller without moving focus first
