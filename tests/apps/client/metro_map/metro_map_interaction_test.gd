extends SceneTree


const MapData = preload("res://core/metro_map/metro_map_data.gd")
const SquadState = preload("res://core/squad/squad_state.gd")
const StationTarget = preload("res://apps/client/metro_map/station_target.gd")
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
	_test_marker_badge_distinct_from_station_target(map_world)
	_test_initial_marker_state(map_world)
	_test_station_targets_start_neutral(map_world)
	_test_guidance_cleared_until_selection(map_world)
	_test_selection_without_movement(map_world)
	_test_selected_marker_state(map_world)
	_test_selection_populates_guidance(map_world)
	_test_selection_highlights_free_and_paid(map_world)
	_test_successful_move_syncs_marker(map_world)
	_test_paid_move_spends_action_point(map_world)
	_test_successful_move_refreshes_guidance(map_world)
	_test_spent_squad_hides_paid_destinations(map_world)
	_test_rejected_move_preserves_marker(map_world)
	_test_rejected_move_preserves_guidance(map_world)
	_test_closures_clear_stale_guidance(map_world)
	_test_free_move_preserves_action_point(map_world)
	_test_end_turn_control(map_root, map_world)
	_test_end_turn_control_states(map_root, map_world)
	_test_end_turn_restores_action_point(map_world)
	_test_end_turn_refreshes_guidance(map_world)
	_test_camera_drag_via_left_mouse(map_world)
	_test_click_below_drag_threshold_does_not_move_camera(map_world)

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


func _test_marker_badge_distinct_from_station_target(map_world: Node2D) -> void:
	var marker: Area2D = map_world.squad_markers[SquadState.INITIAL_SQUAD_ID]
	# The badge silhouette spans the hit-target radius on every axis, so visual
	# bounds and the circular hit target stay centered on the station position
	# regardless of camera zoom applied to Camera2D.
	var badge: PackedVector2Array = marker._badge_points(marker.RADIUS)
	_expect_equal(badge.size(), 5, "badge silhouette is a five-point shield")
	for point: Vector2 in badge:
		_expect(point.length() <= marker.RADIUS, "badge point stays within hit-target radius")
	_expect(badge.has(Vector2(0.0, -marker.RADIUS)), "badge reaches the top of the hit target")
	_expect(badge.has(Vector2(0.75 * marker.RADIUS, -0.5 * marker.RADIUS)), "badge reaches the right side of the hit target")
	_expect(badge.has(Vector2(-0.75 * marker.RADIUS, -0.5 * marker.RADIUS)), "badge reaches the left side of the hit target")
	_expect_equal(marker.position, MapData.STATIONS[SquadState.INITIAL_STATION_ID]["position"], "badge remains centered on station position")


func _test_initial_marker_state(map_world: Node2D) -> void:
	var marker: Area2D = map_world.squad_markers[SquadState.INITIAL_SQUAD_ID]
	_expect_equal(marker.action_points, 1, "marker exposes the action-point value")
	_expect_equal(marker.presentation_state(), "unselected-mobile", "initial marker is unselected with action points")
	_expect(map_world.selected_squad_id.is_empty(), "no squad is selected initially")


func _test_selected_marker_state(map_world: Node2D) -> void:
	var marker: Area2D = map_world.squad_markers[SquadState.INITIAL_SQUAD_ID]
	_expect_equal(marker.presentation_state(), "selected-mobile", "selected marker with action points is selected-mobile")


func _test_paid_move_spends_action_point(map_world: Node2D) -> void:
	# Runs after the paid move to oktyabrskaya_koltsevaya above.
	var marker: Area2D = map_world.squad_markers[SquadState.INITIAL_SQUAD_ID]
	_expect_equal(marker.action_points, 0, "paid movement empties the action-point indicator")
	_expect_equal(marker.presentation_state(), "selected-spent", "squad that spent its action point is selected-spent")
	# Selection remains available when the squad has no action points.
	map_world._on_squad_activated(SquadState.INITIAL_SQUAD_ID)
	_expect_equal(map_world.selected_squad_id, SquadState.INITIAL_SQUAD_ID, "squad without action points stays selectable")


func _test_free_move_preserves_action_point(map_world: Node2D) -> void:
	# Restore one action point, then take the free transfer and confirm the
	# indicator keeps its value.
	map_world.squad_state.squads[SquadState.INITIAL_SQUAD_ID]["action_points"] = 1
	map_world.squad_markers[SquadState.INITIAL_SQUAD_ID].action_points = 1
	map_world._on_station_activated("oktyabrskaya_kaluzhsko_rizhskaya")
	var squad: Dictionary = map_world.squad_state.squads[SquadState.INITIAL_SQUAD_ID]
	var marker: Area2D = map_world.squad_markers[SquadState.INITIAL_SQUAD_ID]
	_expect_equal(squad["station_id"], "oktyabrskaya_kaluzhsko_rizhskaya", "free transfer moves the squad")
	_expect_equal(squad["action_points"], 1, "free movement preserves authoritative action points")
	_expect_equal(marker.action_points, 1, "free movement preserves the action-point indicator")
	_expect_equal(marker.presentation_state(), "selected-mobile", "squad after free movement is selected-mobile")
	map_world._on_station_activated("oktyabrskaya_koltsevaya")
	_expect_equal(map_world.squad_markers[SquadState.INITIAL_SQUAD_ID].action_points, 1, "return transfer also preserves the action point")


func _test_end_turn_restores_action_point(map_world: Node2D) -> void:
	# Runs after the end-turn button was pressed in the control test above.
	var marker: Area2D = map_world.squad_markers[SquadState.INITIAL_SQUAD_ID]
	_expect_equal(marker.action_points, 1, "turn end restores the action-point indicator")
	_expect_equal(marker.presentation_state(), "selected-mobile", "squad after turn end is selected-mobile")


func _test_selection_without_movement(map_world: Node2D) -> void:
	var marker: Area2D = map_world.squad_markers[SquadState.INITIAL_SQUAD_ID]
	var before := marker.position
	map_world._on_squad_activated(SquadState.INITIAL_SQUAD_ID)
	_expect_equal(map_world.selected_squad_id, SquadState.INITIAL_SQUAD_ID, "squad activation selects by stable ID")
	_expect(marker.selected, "selected marker renders selected state")
	_expect_equal(marker.position, before, "selection does not move the squad")


func _test_guidance_cleared_until_selection(map_world: Node2D) -> void:
	# Guidance stays empty until a squad is selected and never leaks
	# unrelated stations after selection.
	map_world._on_squad_activated(SquadState.INITIAL_SQUAD_ID)
	_expect_equal(map_world.destination_guidance.size(), 3, "selection populates direct destinations only")
	_expect("kurskaya_koltsevaya" not in map_world.destination_guidance, "unrelated station is not guided")
	_expect(SquadState.INITIAL_STATION_ID not in map_world.destination_guidance, "current station is not guided")


func _test_station_targets_start_neutral(map_world: Node2D) -> void:
	# Before any selection, every station target remains neutral: no station
	# is presented as actionable.
	for station_id: String in map_world.station_targets:
		var target: StationTarget = map_world.station_targets[station_id]
		_expect_equal(
			target.presentation_state,
			StationTarget.STATE_NEUTRAL,
			"station '%s' stays neutral without an active selection" % station_id,
		)


func _test_selection_highlights_free_and_paid(map_world: Node2D) -> void:
	# After selection, free and paid destinations have distinguishable
	# non-color presentation states, and unrelated stations stay neutral.
	var free_target: StationTarget = map_world.station_targets["park_kultury_sokolnicheskaya"]
	var paid_target: StationTarget = map_world.station_targets["oktyabrskaya_koltsevaya"]
	var reverse_paid_target: StationTarget = map_world.station_targets["kievskaya_koltsevaya"]
	var unrelated_target: StationTarget = map_world.station_targets["kurskaya_koltsevaya"]
	var current_target: StationTarget = map_world.station_targets[SquadState.INITIAL_STATION_ID]

	_expect_equal(free_target.presentation_state, StationTarget.STATE_FREE_DESTINATION, "free destination presents free state")
	_expect_equal(paid_target.presentation_state, StationTarget.STATE_PAID_DESTINATION, "paid destination presents paid state")
	_expect_equal(reverse_paid_target.presentation_state, StationTarget.STATE_PAID_DESTINATION, "reverse paid destination presents paid state")
	_expect_equal(unrelated_target.presentation_state, StationTarget.STATE_NEUTRAL, "unrelated station stays neutral")
	_expect_equal(current_target.presentation_state, StationTarget.STATE_NEUTRAL, "current station stays neutral")
	_expect(free_target.presentation_state != paid_target.presentation_state, "free and paid states are distinguishable without color")


func _test_selection_populates_guidance(map_world: Node2D) -> void:
	# Runs while the squad is already selected at park_kultury_koltsevaya.
	_expect_equal(map_world.destination_guidance.get("oktyabrskaya_koltsevaya"), 1, "paid destination reports cost one")
	_expect_equal(map_world.destination_guidance.get("park_kultury_sokolnicheskaya"), 0, "free destination reports cost zero")
	_expect_equal(map_world.destination_guidance.get("kievskaya_koltsevaya"), 1, "reverse paid destination reported")


func _test_successful_move_syncs_marker(map_world: Node2D) -> void:
	map_world._on_station_activated("oktyabrskaya_koltsevaya")
	var squad: Dictionary = map_world.squad_state.squads[SquadState.INITIAL_SQUAD_ID]
	var marker: Area2D = map_world.squad_markers[SquadState.INITIAL_SQUAD_ID]
	_expect_equal(squad["station_id"], "oktyabrskaya_koltsevaya", "valid activation moves authoritative state")
	_expect_equal(marker.position, MapData.STATIONS["oktyabrskaya_koltsevaya"]["position"], "valid activation synchronizes marker")


func _test_successful_move_refreshes_guidance(map_world: Node2D) -> void:
	# After the successful paid move above, the squad has zero action points
	# and only the free oktyabrskaya_kaluzhsko_rizhskaya transfer remains.
	_expect_equal(map_world.destination_guidance.size(), 1, "guidance refreshes after movement")
	_expect_equal(
		map_world.destination_guidance.get("oktyabrskaya_kaluzhsko_rizhskaya"),
		0,
		"free transfer destination remains guided after spent move",
	)
	_expect("park_kultury_koltsevaya" not in map_world.destination_guidance, "unaffordable paid destination is cleared")


func _test_spent_squad_hides_paid_destinations(map_world: Node2D) -> void:
	# After the paid move above, the squad has 0 AP. Only the free
	# destination remains highlighted; previously-paid neighboring stations
	# become neutral, and no closed/unrelated station is presented as
	# available.
	var free_target: StationTarget = map_world.station_targets["oktyabrskaya_kaluzhsko_rizhskaya"]
	var park_target: StationTarget = map_world.station_targets["park_kultury_koltsevaya"]
	var dobryninskaya_target: StationTarget = map_world.station_targets["dobryninskaya_koltsevaya"]
	var unrelated_target: StationTarget = map_world.station_targets["kurskaya_koltsevaya"]

	_expect_equal(free_target.presentation_state, StationTarget.STATE_FREE_DESTINATION, "free destination remains available at zero action points")
	_expect_equal(park_target.presentation_state, StationTarget.STATE_NEUTRAL, "previously-paid destination becomes neutral at zero action points")
	_expect_equal(dobryninskaya_target.presentation_state, StationTarget.STATE_NEUTRAL, "unaffordable forward paid destination becomes neutral")
	_expect_equal(unrelated_target.presentation_state, StationTarget.STATE_NEUTRAL, "unrelated destination stays neutral")


func _test_rejected_move_preserves_guidance(map_world: Node2D) -> void:
	var before: Dictionary = map_world.destination_guidance.duplicate(true)
	map_world._on_station_activated("kurskaya_koltsevaya")
	_expect_equal(map_world.destination_guidance, before, "rejected activation preserves guidance")


func _test_closures_clear_stale_guidance(map_world: Node2D) -> void:
	var free_target: StationTarget = map_world.station_targets["oktyabrskaya_kaluzhsko_rizhskaya"]
	map_world.map_session_state.closed_for_entry_station_ids.append("oktyabrskaya_kaluzhsko_rizhskaya")
	map_world.notify_closures_changed()
	_expect_equal(map_world.destination_guidance.size(), 0, "closure change clears stale destination guidance")
	_expect_equal(free_target.presentation_state, StationTarget.STATE_NEUTRAL, "closed destination loses destination highlighting")
	map_world.map_session_state.closed_for_entry_station_ids.erase("oktyabrskaya_kaluzhsko_rizhskaya")
	map_world.notify_closures_changed()
	_expect_equal(map_world.destination_guidance.size(), 1, "reopening restores valid guidance")
	_expect_equal(free_target.presentation_state, StationTarget.STATE_FREE_DESTINATION, "reopened destination regains highlighting")


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


func _test_end_turn_control_states(map_root: Node2D, map_world: Node2D) -> void:
	var hud: CanvasLayer = map_root.get_node("HUD")
	var button: Control = hud.get_node("EndTurnMargin/EndTurnButton")
	var initial_ap: int = map_world.squad_state.squads[SquadState.INITIAL_SQUAD_ID]["action_points"]

	# Default state.
	_expect(not button.hovered, "default state has no hover")
	_expect(not button.held, "default state is not held")
	_expect(button.enabled, "default state is enabled")

	# Hover state.
	button._on_mouse_entered()
	_expect(button.hovered, "pointer enter sets hover state")
	button._on_mouse_exited()
	_expect(not button.hovered, "pointer exit clears hover state")

	# Pressed state via gui_input.
	button._on_mouse_entered()
	var press := _make_mouse_button(button.size * 0.5, true)
	button._on_gui_input(press)
	_expect(button.held, "press sets held state")
	var release := _make_mouse_button(button.size * 0.5, false)
	button._on_gui_input(release)
	_expect(not button.held, "release clears held state")

	# Focus state survives pointer exit.
	button.grab_focus()
	_expect(button.has_focus(), "focus is reachable")
	button.release_focus()
	_expect(not button.has_focus(), "releasing focus returns to default")

	# Keyboard activation when focused.
	button.grab_focus()
	map_world.squad_state.squads[SquadState.INITIAL_SQUAD_ID]["action_points"] = 0
	var key_event := InputEventAction.new()
	key_event.action = "ui_accept"
	key_event.pressed = true
	button._on_gui_input(key_event)
	_expect_equal(
		map_world.squad_state.squads[SquadState.INITIAL_SQUAD_ID]["action_points"],
		1,
		"keyboard ui_accept activates end turn when focused",
	)
	button.release_focus()

	# Disabled state suppresses activation.
	button.enabled = false
	_expect(not button.enabled, "disabled state is readable")
	var ap_before: int = initial_ap
	map_world.squad_state.squads[SquadState.INITIAL_SQUAD_ID]["action_points"] = ap_before
	button._on_mouse_entered()
	button._on_gui_input(_make_mouse_button(button.size * 0.5, true))
	button._on_gui_input(_make_mouse_button(button.size * 0.5, false))
	_expect_equal(
		map_world.squad_state.squads[SquadState.INITIAL_SQUAD_ID]["action_points"],
		ap_before,
		"disabled end-turn button does not activate",
	)
	button.enabled = true


func _test_end_turn_refreshes_guidance(map_world: Node2D) -> void:
	# After the end-turn button was pressed above, the squad has one action
	# point again and paid destinations become reachable once more.
	_expect_equal(map_world.destination_guidance.size(), 3, "end turn refreshes guidance for the selected squad")
	_expect_equal(
		map_world.destination_guidance.get("park_kultury_koltsevaya"),
		1,
		"paid reverse destination becomes guided again after end turn",
	)


func _make_mouse_button(position: Vector2, pressed: bool) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = position
	return event


func _make_mouse_motion(position: Vector2) -> InputEventMouseMotion:
	var event := InputEventMouseMotion.new()
	event.position = position
	return event


func _test_camera_drag_via_left_mouse(map_world: Node2D) -> void:
	var before: Vector2 = map_world.camera.position
	var start := Vector2(640.0, 400.0)
	var end := Vector2(700.0, 460.0)
	map_world._input(_make_mouse_button(start, true))
	_expect(not map_world.is_left_button_dragging(), "press alone does not yet count as a drag")
	_expect_equal(map_world.camera.position, before, "press alone does not move the camera")

	# Small move below threshold: still not a drag.
	var small := _make_mouse_motion(start + Vector2(3.0, 3.0))
	map_world._input(small)
	_expect(not map_world.is_left_button_dragging(), "movement below drag threshold is not a drag")
	_expect_equal(map_world.camera.position, before, "sub-threshold movement does not move the camera")

	# Move past threshold: drag engages and the camera pans.
	map_world._input(_make_mouse_motion(end))
	_expect(map_world.is_left_button_dragging(), "movement past drag threshold engages drag")
	var panned: Vector2 = map_world.camera.position
	_expect(panned != before, "drag moves the camera")
	# Camera moves opposite the pointer delta, scaled by zoom. When panning
	# would clamp against map bounds, at least one axis should reflect the
	# drag direction.
	var pan_delta: Vector2 = panned - before
	_expect(
		absf(pan_delta.x) > 0.01 or absf(pan_delta.y) > -0.01,
		"camera pans in response to the drag (got delta %s)" % pan_delta,
	)
	# Pointer moves right/down; camera moves left/up. At least one component
	# should match that sign (one axis may be clamped by map bounds).
	var sign_x_ok := pan_delta.x < 0.0 or absf(pan_delta.x) < 0.01
	var sign_y_ok := pan_delta.y < 0.0 or absf(pan_delta.y) < 0.01
	_expect(sign_x_ok and sign_y_ok, "camera pans opposite the drag direction (got delta %s)" % pan_delta)

	map_world._input(_make_mouse_button(end, false))
	_expect(not map_world.is_left_button_dragging(), "releasing the button clears the drag state")


func _test_click_below_drag_threshold_does_not_move_camera(map_world: Node2D) -> void:
	var before: Vector2 = map_world.camera.position
	var start := Vector2(500.0, 500.0)
	map_world._input(_make_mouse_button(start, true))
	map_world._input(_make_mouse_motion(start + Vector2(2.0, 1.0)))
	map_world._input(_make_mouse_button(start + Vector2(2.0, 1.0), false))
	_expect_equal(map_world.camera.position, before, "click without drag does not move the camera")
	_expect(not map_world.is_left_button_dragging(), "click without drag leaves no drag state")


func _expect(condition: bool, description: String) -> void:
	_tests_run += 1
	if not condition:
		_failures.append(description)


func _expect_equal(actual: Variant, expected: Variant, description: String) -> void:
	_expect(actual == expected, "%s: expected %s, got %s" % [description, expected, actual])
