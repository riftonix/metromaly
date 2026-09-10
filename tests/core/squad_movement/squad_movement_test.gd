extends SceneTree


const MapData = preload("res://core/metro_map/metro_map_data.gd")
const MovementController = preload("res://core/squad_movement/squad_movement_controller.gd")
const MapSessionState = preload("res://core/metro_map/metro_map_session_state.gd")
const SquadState = preload("res://core/squad/squad_state.gd")
const TurnController = preload("res://core/squad_movement/squad_turn_controller.gd")

var _failures: Array[String] = []
var _tests_run := 0


func _initialize() -> void:
	_test_paid_move()
	_test_unknown_squad_rejection_is_atomic()
	_test_reverse_move()
	_test_current_station_rejection_is_atomic()
	_test_unrelated_station_rejection_is_atomic()
	_test_unknown_destination_rejection_is_atomic()
	_test_free_transfer()
	_test_insufficient_action_points_is_atomic()
	_test_closed_destination_is_atomic()
	_test_leaving_closed_station()
	_test_reopened_station()
	_test_end_turn_with_one_squad()
	_test_end_turn_with_multiple_squads()

	if _failures.is_empty():
		print("Squad movement tests passed (%d tests)" % _tests_run)
		quit(0)
		return

	for failure: String in _failures:
		printerr(failure)
	printerr("Squad movement tests failed (%d failures)" % _failures.size())
	quit(1)


func _test_paid_move() -> void:
	var state := SquadState.create_initial()
	var result := _move(state, MapSessionState.new(), "oktyabrskaya_koltsevaya")
	var squad: Dictionary = state.squads[SquadState.INITIAL_SQUAD_ID]
	_expect(result["success"], "paid connected move succeeds")
	_expect_equal(result["cost"], 1, "paid move reports its cost")
	_expect_equal(squad["station_id"], "oktyabrskaya_koltsevaya", "paid move changes station")
	_expect_equal(squad["action_points"], 0, "paid move consumes one action point")


func _test_unknown_squad_rejection_is_atomic() -> void:
	var state := SquadState.create_initial()
	var map_state := MapSessionState.new()
	var before: Dictionary = state.squads.duplicate(true)
	var result := MovementController.try_move(
		state.squads,
		map_state.closed_for_entry_station_ids,
		"missing_squad",
		"oktyabrskaya_koltsevaya",
		MapData.STATIONS,
		MapData.CONNECTIONS,
	)
	_expect_equal(
		result["reason"],
		MovementController.REJECTION_UNKNOWN_SQUAD,
		"unknown squad is rejected",
	)
	_expect_equal(state.squads, before, "unknown-squad rejection is atomic")


func _test_reverse_move() -> void:
	var state := _state_at("oktyabrskaya_koltsevaya", 1)
	var result := _move(state, MapSessionState.new(), SquadState.INITIAL_STATION_ID)
	_expect(result["success"], "reverse declared connection succeeds")
	_expect_equal(
		state.squads[SquadState.INITIAL_SQUAD_ID]["station_id"],
		SquadState.INITIAL_STATION_ID,
		"reverse move changes station",
	)


func _test_current_station_rejection_is_atomic() -> void:
	var state := SquadState.create_initial()
	var before: Dictionary = state.squads[SquadState.INITIAL_SQUAD_ID].duplicate(true)
	var result := _move(state, MapSessionState.new(), SquadState.INITIAL_STATION_ID)
	_expect_equal(result["reason"], MovementController.REJECTION_CURRENT_STATION, "current station is rejected")
	_expect_equal(state.squads[SquadState.INITIAL_SQUAD_ID], before, "current-station rejection is atomic")


func _test_unrelated_station_rejection_is_atomic() -> void:
	var state := SquadState.create_initial()
	var before: Dictionary = state.squads[SquadState.INITIAL_SQUAD_ID].duplicate(true)
	var result := _move(state, MapSessionState.new(), "kurskaya_koltsevaya")
	_expect_equal(result["reason"], MovementController.REJECTION_NO_CONNECTION, "unrelated station is rejected")
	_expect_equal(state.squads[SquadState.INITIAL_SQUAD_ID], before, "unrelated rejection is atomic")


func _test_unknown_destination_rejection_is_atomic() -> void:
	var state := SquadState.create_initial()
	var before: Dictionary = state.squads[SquadState.INITIAL_SQUAD_ID].duplicate(true)
	var result := _move(state, MapSessionState.new(), "missing_station")
	_expect_equal(
		result["reason"],
		MovementController.REJECTION_UNKNOWN_DESTINATION,
		"unknown destination is rejected",
	)
	_expect_equal(state.squads[SquadState.INITIAL_SQUAD_ID], before, "unknown destination rejection is atomic")


func _test_free_transfer() -> void:
	var state := SquadState.create_initial()
	var result := _move(state, MapSessionState.new(), "park_kultury_sokolnicheskaya")
	var squad: Dictionary = state.squads[SquadState.INITIAL_SQUAD_ID]
	_expect(result["success"], "free transfer succeeds")
	_expect_equal(squad["station_id"], "park_kultury_sokolnicheskaya", "free transfer changes station")
	_expect_equal(squad["action_points"], 1, "free transfer preserves action points")


func _test_insufficient_action_points_is_atomic() -> void:
	var state := _state_at(SquadState.INITIAL_STATION_ID, 0)
	var before: Dictionary = state.squads[SquadState.INITIAL_SQUAD_ID].duplicate(true)
	var result := _move(state, MapSessionState.new(), "oktyabrskaya_koltsevaya")
	_expect_equal(
		result["reason"],
		MovementController.REJECTION_INSUFFICIENT_ACTION_POINTS,
		"paid move without action points is rejected",
	)
	_expect_equal(state.squads[SquadState.INITIAL_SQUAD_ID], before, "insufficient-points rejection is atomic")


func _test_closed_destination_is_atomic() -> void:
	var state := SquadState.create_initial()
	var map_state := MapSessionState.new(["oktyabrskaya_koltsevaya"])
	var before: Dictionary = state.squads[SquadState.INITIAL_SQUAD_ID].duplicate(true)
	var result := _move(state, map_state, "oktyabrskaya_koltsevaya")
	_expect_equal(
		result["reason"],
		MovementController.REJECTION_DESTINATION_CLOSED,
		"closed destination is rejected",
	)
	_expect_equal(state.squads[SquadState.INITIAL_SQUAD_ID], before, "closure rejection is atomic")


func _test_leaving_closed_station() -> void:
	var state := _state_at(SquadState.INITIAL_STATION_ID, 1)
	var map_state := MapSessionState.new([SquadState.INITIAL_STATION_ID])
	var result := _move(state, map_state, "oktyabrskaya_koltsevaya")
	_expect(result["success"], "squad can leave a closed station")


func _test_reopened_station() -> void:
	var state := SquadState.create_initial()
	var map_state := MapSessionState.new(["oktyabrskaya_koltsevaya"])
	map_state.closed_for_entry_station_ids.erase("oktyabrskaya_koltsevaya")
	var result := _move(state, map_state, "oktyabrskaya_koltsevaya")
	_expect(result["success"], "removing closure restores entry")


func _test_end_turn_with_one_squad() -> void:
	var state := _state_at(SquadState.INITIAL_STATION_ID, 0)
	TurnController.end_turn(state.squads)
	_expect_equal(
		state.squads[SquadState.INITIAL_SQUAD_ID]["action_points"],
		1,
		"end turn restores the initial squad to one action point",
	)


func _test_end_turn_with_multiple_squads() -> void:
	var state := _state_at(SquadState.INITIAL_STATION_ID, 0)
	state.squads["player_squad_2"] = {
		"station_id": "oktyabrskaya_koltsevaya",
		"action_points": 1,
	}
	TurnController.end_turn(state.squads)
	for squad_id: String in state.squads:
		_expect_equal(
			state.squads[squad_id]["action_points"],
			1,
			"end turn sets squad '%s' to exactly one action point" % squad_id,
		)


func _state_at(station_id: String, action_points: int) -> RefCounted:
	return SquadState.new(
		{
			SquadState.INITIAL_SQUAD_ID: {
				"station_id": station_id,
				"action_points": action_points,
			},
		},
	)


func _move(state: RefCounted, map_state: RefCounted, destination_station_id: String) -> Dictionary:
	return MovementController.try_move(
		state.squads,
		map_state.closed_for_entry_station_ids,
		SquadState.INITIAL_SQUAD_ID,
		destination_station_id,
		MapData.STATIONS,
		MapData.CONNECTIONS,
	)


func _expect(condition: bool, description: String) -> void:
	_tests_run += 1
	if not condition:
		_failures.append(description)


func _expect_equal(actual: Variant, expected: Variant, description: String) -> void:
	_expect(actual == expected, "%s: expected %s, got %s" % [description, expected, actual])

