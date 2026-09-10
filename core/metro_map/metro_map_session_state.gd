class_name MetroMapSessionState
extends RefCounted


var closed_for_entry_station_ids: Array[String] = []


func _init(initial_closed_for_entry_station_ids: Array[String] = []) -> void:
	closed_for_entry_station_ids.assign(initial_closed_for_entry_station_ids)
