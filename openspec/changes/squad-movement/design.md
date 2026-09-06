## Context

The metro map is a `Node2D` world viewed through `Camera2D`. `MetroMapData` provides stations in SVG coordinates and unordered direct connections with costs of zero or one. The map currently has no station hit targets, squad state, selection state, or fixed screen-space gameplay controls.

## Goals / Non-Goals

**Goals:**

- Keep squad state independent per squad and address squads by stable ID.
- Reuse `MetroGraph` direct-connection lookup as the only source of movement adjacency and cost.
- Keep map-space markers under the camera and the `End Turn` control outside it.
- Make closure checks directional by evaluating only the movement destination.
- Keep the first visual implementation small while allowing the squad collection to grow.

**Non-Goals:**

- Multi-edge pathfinding or queued movement.
- Movement animation, combat, ownership, recruitment, persistence, or multiplayer turn order.
- More than one initial squad or UI for creating squads.
- Dynamic action-point maximums or action-point values above one.

## Architecture and Component Boundaries

### Architecture Overview

The map scene owns interaction presentation and delegates movement decisions to a gameplay controller. Station hit targets and squad markers live in the camera-transformed map world. Fixed HUD controls live in a `CanvasLayer` or equivalent screen-space UI. The controller reads immutable station and connection data while owning mutable squads, selection, closure state, and turn transitions.

### Component Responsibilities

- Station hit targets publish station IDs when activated.
- Squad markers publish squad IDs when activated and render at the associated station position.
- The movement controller owns the squad collection, selected squad ID, `closed_for_entry_station_ids`, movement checks, and successful state changes.
- The turn controller resets action points across the complete squad collection.
- `MetroGraph` reports direct connection cost without owning gameplay state.

### Component Boundaries

The SVG remains presentation-only and is not used for hit testing. Station interaction uses `MetroMapData.STATIONS` positions. The movement controller does not infer adjacency from screen distance or line geometry.

## Component Changes

### Metro Map Scene

Create station hit areas from the station catalog and one initial squad marker from initial squad state. Route marker activation to the gameplay controller. Add a fixed `End Turn` button outside `MapWorld` so camera movement and zoom do not transform it.

### Squad State

Store squads in a dictionary keyed by stable squad ID. Each record contains `station_id` and `action_points`. Keep the selected squad as an ID rather than a direct node reference so presentation nodes can be rebuilt without invalidating gameplay state.

### Movement Controller

Evaluate a move in this order: selected squad exists, destination station exists, destination differs from origin, direct connection exists, destination is not closed for entry, and available action points cover the cost. Mutate `station_id`, marker position, and action points only after all checks pass.

### Turn Control

Iterate over every squad record and assign one action point. This intentionally supports multiple squads from the first implementation even though only one initial record is created.

## Data Model

### Entities and Relationships

- A squad has a stable ID, one current station ID, and zero or one action point.
- The squad collection contains zero or more independently mutable squad records.
- `selected_squad_id` is empty or references one squad in the collection.
- `closed_for_entry_station_ids: Array[String]` contains unique destination station IDs.

### Ownership and Lifecycle

Squad and closure state is mutable gameplay state owned by the map session. `MetroMapData` remains immutable topology. Persistence is deferred.

## Interfaces

### User Interface

Squad and station markers must remain individually clickable when they overlap. A click on a squad selects it and must not also trigger movement to the underlying station. The `End Turn` button remains fixed to the viewport.

### Internal Interfaces

Movement consumes a squad ID and destination station ID and returns a success or rejection result. Rejection is atomic and changes neither squad location nor action points. Turn end operates on the complete squad collection rather than the currently selected squad.

## Error Handling

### Error Categories

Expected gameplay rejections include no selected squad, unrelated destination, insufficient action points, and closed destination. Invalid internal state includes unknown squad IDs, unknown station IDs, invalid action points, and duplicate closure entries.

### Logging and Diagnostics

Expected rejected clicks do not require error logs. Validation diagnostics identify the offending squad or station ID. Unexpected references encountered by the controller produce concise diagnostics without partially changing state.

## Decisions

### Decision: Keep closures separate from connection costs

Connections describe stable topology and cost, while closures describe mutable session state. Encoding closure as another connection cost was rejected because it mixes availability with movement cost and cannot express entry-only blocking cleanly.

### Decision: Store closure IDs in a typed array

The closure collection is expected to remain small, so `Array[String]` provides the clearest editable and serializable representation. A dictionary used as a set was rejected as unnecessary optimization for the initial scope.

### Decision: Model multiple squads before displaying them

Movement and turn reset operate on a squad dictionary from the start. A single global squad record was rejected because it would require immediate restructuring when a second squad is introduced.

### Decision: Move instantly between station positions

Successful movement updates the marker directly to the destination coordinates. Tweening was rejected for this slice because it adds interaction locking and interruption behavior unrelated to validating movement rules.

## Risks / Trade-offs

- [A squad marker overlaps its station hit target] -> Give squad activation priority and stop propagation before station movement handling.
- [Free transfers allow repeated movement with zero action points] -> Preserve this behavior because the map data explicitly assigns transfer cost zero.
- [A typed array uses linear membership checks] -> Keep it for clarity while closure counts are small; replace behind the controller interface only if profiling establishes a need.
- [Direct marker updates can desynchronize from squad state] -> Treat the squad record as authoritative and refresh marker position from its station after successful mutation.
