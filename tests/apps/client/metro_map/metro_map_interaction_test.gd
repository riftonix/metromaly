extends SceneTree


const MapData = preload("res://core/metro_map/metro_map_data.gd")
const SquadState = preload("res://core/squad/squad_state.gd")
const MAP_SCENE := "res://apps/client/metro_map/metro_map.tscn"

var _failures: Array[String] = []
var _tests_run := 0


func _initialize() -> void:
	var packed_scene: PackedScene = load(MAP_SCENE)
	var map_root := packed_scene.instantiate()
	root.add_child.call_deferred(map_root)
	await process_frame

	var map_world: Node2D = map_root.get_node("MapWorld")
	if not map_world.squad_markers.has(SquadState.INITIAL_SQUAD_ID):
		_failures.append("initial squad marker was not created")
		_finish(map_root)
		return
	_test_station_targets(map_world)
	_test_initial_squad_marker(map_world)
	_test_selection_without_movement(map_world)
	_test_successful_move_syncs_marker(map_world)
	_test_rejected_move_preserves_marker(map_world)
	_test_end_turn_control(map_root, map_world)

	_finish(map_root)


func _finish(map_root: Node2D) -> void:
	map_root.queue_free()
	if _failures.is_empty():
		print("Metro map interaction tests passed (%d tests)" % _tests_run)
		quit(0)
		return

	for failure: String in _failures:
		printerr(failure)
	printerr("Metro map interaction tests failed (%d failures)" % _failures.size())
	quit(1)


func _test_station_targets(map_world: Node2D) -> void:
	_expect_equal(map_world.station_targets.size(), MapData.STATIONS.size(), "every station has a target")
	for station_id: String in MapData.STATIONS:
		var target: Area2D = map_world.station_targets[station_id]
		_expect_equal(target.station_id, station_id, "station target publishes stable ID")
		_expect_equal(target.position, MapData.STATIONS[station_id]["position"], "station target uses map position")
	_expect(
		map_world.station_targets.values()[0].is_ancestor_of(map_world.camera) == false,
		"station targets remain in map space outside the camera node",
	)


func _test_initial_squad_marker(map_world: Node2D) -> void:
	var marker: Area2D = map_world.squad_markers[SquadState.INITIAL_SQUAD_ID]
	_expect_equal(map_world.squad_markers.size(), 1, "one initial squad marker is rendered")
	_expect_equal(marker.squad_id, SquadState.INITIAL_SQUAD_ID, "marker publishes stable squad ID")
	_expect_equal(marker.position, MapData.STATIONS[SquadState.INITIAL_STATION_ID]["position"], "marker is centered on its station")
	_expect_equal(marker.RADIUS, map_world.station_targets[SquadState.INITIAL_STATION_ID].RADIUS, "squad and station targets have equal diameter")
	_expect(marker.z_index > map_world.station_targets[SquadState.INITIAL_STATION_ID].z_index, "squad marker has overlap priority")


func _test_selection_without_movement(map_world: Node2D) -> void:
	var marker: Area2D = map_world.squad_markers[SquadState.INITIAL_SQUAD_ID]
	var before := marker.position
	map_world._on_squad_activated(SquadState.INITIAL_SQUAD_ID)
	_expect_equal(map_world.selected_squad_id, SquadState.INITIAL_SQUAD_ID, "squad activation selects by stable ID")
	_expect(marker.selected, "selected marker renders selected state")
	_expect_equal(marker.position, before, "selection does not move the squad")


func _test_successful_move_syncs_marker(map_world: Node2D) -> void:
	map_world._on_station_activated("oktyabrskaya_koltsevaya")
	var squad: Dictionary = map_world.squad_state.squads[SquadState.INITIAL_SQUAD_ID]
	var marker: Area2D = map_world.squad_markers[SquadState.INITIAL_SQUAD_ID]
	_expect_equal(squad["station_id"], "oktyabrskaya_koltsevaya", "valid activation moves authoritative state")
	_expect_equal(marker.position, MapData.STATIONS["oktyabrskaya_koltsevaya"]["position"], "valid activation synchronizes marker")


func _test_rejected_move_preserves_marker(map_world: Node2D) -> void:
	var marker: Area2D = map_world.squad_markers[SquadState.INITIAL_SQUAD_ID]
	var before_position := marker.position
	var before_squad: Dictionary = map_world.squad_state.squads[SquadState.INITIAL_SQUAD_ID].duplicate(true)
	map_world._on_station_activated("kurskaya_koltsevaya")
	_expect_equal(marker.position, before_position, "rejected activation preserves marker position")
	_expect_equal(map_world.squad_state.squads[SquadState.INITIAL_SQUAD_ID], before_squad, "rejected activation preserves squad state")


func _test_end_turn_control(map_root: Node2D, map_world: Node2D) -> void:
	var hud: CanvasLayer = map_root.get_node("HUD")
	var margin: MarginContainer = hud.get_node("EndTurnMargin")
	var button: Control = margin.get_node("EndTurnButton")
	_expect(hud.get_parent() == map_root, "HUD is outside the camera-transformed map world")
	_expect_equal(margin.anchor_left, 1.0, "end-turn control is anchored to the right edge")
	_expect_equal(margin.anchor_top, 1.0, "end-turn control is anchored to the bottom edge")
	_expect_equal(button.tooltip_text, "End Turn", "icon-only control has an accessible tooltip")
	_expect_equal(button.custom_minimum_size, Vector2(64.0, 64.0), "end-turn button has an icon-sized square layout")

	map_world.squad_state.squads[SquadState.INITIAL_SQUAD_ID]["action_points"] = 0
	button.pressed.emit()
	_expect_equal(
		map_world.squad_state.squads[SquadState.INITIAL_SQUAD_ID]["action_points"],
		1,
		"end-turn button restores action points",
	)


func _expect(condition: bool, description: String) -> void:
	_tests_run += 1
	if not condition:
		_failures.append(description)


func _expect_equal(actual: Variant, expected: Variant, description: String) -> void:
	_expect(actual == expected, "%s: expected %s, got %s" % [description, expected, actual])
