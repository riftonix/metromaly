extends SceneTree


const MapData = preload("res://core/metro_map/metro_map_data.gd")
const SquadState = preload("res://core/squad/squad_state.gd")
const SquadValidator = preload("res://core/squad/squad_validator.gd")

var _failures: Array[String] = []
var _tests_run := 0


func _initialize() -> void:
	_test_initial_state()
	_test_second_squad_is_independent()
	_test_valid_state()
	_test_missing_squad_id()
	_test_unknown_squad_station()
	_test_invalid_action_points()

	if _failures.is_empty():
		print("Squad tests passed (%d tests)" % _tests_run)
		quit(0)
		return

	for failure: String in _failures:
		printerr(failure)
	printerr("Squad tests failed (%d failures)" % _failures.size())
	quit(1)


func _test_initial_state() -> void:
	var state := SquadState.create_initial()
	_expect_equal(state.squads.size(), 1, "initial state contains one squad")
	_expect(state.squads.has(SquadState.INITIAL_SQUAD_ID), "initial squad has a stable ID")
	var squad: Dictionary = state.squads[SquadState.INITIAL_SQUAD_ID]
	_expect_equal(squad["station_id"], SquadState.INITIAL_STATION_ID, "initial station is defined")
	_expect_equal(squad["action_points"], 1, "initial squad has one action point")


func _test_second_squad_is_independent() -> void:
	var state := SquadState.create_initial()
	state.squads["player_squad_2"] = {
		"station_id": "oktyabrskaya_koltsevaya",
		"action_points": 0,
	}
	state.squads[SquadState.INITIAL_SQUAD_ID]["action_points"] = 0
	_expect_equal(state.squads.size(), 2, "a second squad uses the same collection structure")
	_expect_equal(state.squads["player_squad_2"]["station_id"], "oktyabrskaya_koltsevaya", "squad stations remain independent")
	_expect_equal(state.squads["player_squad_2"]["action_points"], 0, "changing the first squad does not change the second")


func _test_valid_state() -> void:
	var errors := SquadValidator.validate(SquadState.create_initial().squads, MapData.STATIONS)
	_expect(errors.is_empty(), "valid squad state is accepted: %s" % [errors])


func _test_missing_squad_id() -> void:
	var errors := SquadValidator.validate(
		{"": {"station_id": SquadState.INITIAL_STATION_ID, "action_points": 1}},
		MapData.STATIONS,
	)
	_expect_contains(errors, "Squad ID ''", "missing squad ID is rejected")


func _test_unknown_squad_station() -> void:
	var errors := SquadValidator.validate(
		{"player_squad_1": {"station_id": "missing_station", "action_points": 1}},
		MapData.STATIONS,
	)
	_expect_contains(errors, "Squad 'player_squad_1' references unknown station 'missing_station'", "unknown station identifies squad and station")


func _test_invalid_action_points() -> void:
	for action_points: int in [-1, 2]:
		var errors := SquadValidator.validate(
			{"player_squad_1": {"station_id": SquadState.INITIAL_STATION_ID, "action_points": action_points}},
			MapData.STATIONS,
		)
		_expect_contains(errors, "Squad 'player_squad_1' has invalid action points '%s'" % action_points, "invalid action points are rejected")


func _expect(condition: bool, description: String) -> void:
	_tests_run += 1
	if not condition:
		_failures.append(description)


func _expect_equal(actual: Variant, expected: Variant, description: String) -> void:
	_expect(actual == expected, "%s: expected %s, got %s" % [description, expected, actual])


func _expect_contains(errors: Array[String], fragment: String, description: String) -> void:
	for error: String in errors:
		if fragment in error:
			_expect(true, description)
			return
	_expect(false, "%s: expected '%s' in %s" % [description, fragment, errors])
