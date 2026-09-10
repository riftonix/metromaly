extends SceneTree


const MapData = preload("res://core/metro_map/metro_map_data.gd")
const MapSessionState = preload("res://core/metro_map/metro_map_session_state.gd")
const MapSessionValidator = preload("res://core/metro_map/metro_map_session_validator.gd")

var _failures: Array[String] = []
var _tests_run := 0


func _initialize() -> void:
	_test_initial_state()
	_test_valid_closure()
	_test_unknown_closure_station()
	_test_duplicate_closure_station()

	if _failures.is_empty():
		print("Metro map session tests passed (%d tests)" % _tests_run)
		quit(0)
		return

	for failure: String in _failures:
		printerr(failure)
	printerr("Metro map session tests failed (%d failures)" % _failures.size())
	quit(1)


func _test_initial_state() -> void:
	_expect(MapSessionState.new().closed_for_entry_station_ids.is_empty(), "initial closure state is empty")


func _test_valid_closure() -> void:
	var state := MapSessionState.new(["oktyabrskaya_koltsevaya"])
	var errors := MapSessionValidator.validate(state.closed_for_entry_station_ids, MapData.STATIONS)
	_expect(errors.is_empty(), "valid closure state is accepted: %s" % [errors])


func _test_unknown_closure_station() -> void:
	var errors := MapSessionValidator.validate(["missing_station"], MapData.STATIONS)
	_expect_contains(errors, "Closure entry 0 references unknown station 'missing_station'", "unknown closure identifies its index and station")


func _test_duplicate_closure_station() -> void:
	var station_id := "oktyabrskaya_koltsevaya"
	var errors := MapSessionValidator.validate([station_id, station_id], MapData.STATIONS)
	_expect_contains(errors, "Closure entry 1 duplicates station 'oktyabrskaya_koltsevaya'", "duplicate closure identifies its index and station")


func _expect(condition: bool, description: String) -> void:
	_tests_run += 1
	if not condition:
		_failures.append(description)


func _expect_contains(errors: Array[String], fragment: String, description: String) -> void:
	for error: String in errors:
		if fragment in error:
			_expect(true, description)
			return
	_expect(false, "%s: expected '%s' in %s" % [description, fragment, errors])
