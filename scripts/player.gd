extends RefCounted

# Represents a player in Grid Battle
class_name Player
extends RefCounted

# Player properties
var player_name: String
var player_id: int
var player_color: Color
var units: Array[Unit] = []
var is_ai: bool = false

# Signals
signal unit_added(unit: Unit)
signal unit_removed(unit: Unit)

func _init(name: String, id: int, color: Color, ai: bool = false):
    player_name = name
    player_id = id
    player_color = color
    is_ai = ai

func add_unit(unit: Unit) -> void:
    if unit not in units:
        units.append(unit)
        unit.owner_player = self
        unit_added.emit(unit)

func remove_unit(unit: Unit) -> void:
    if unit in units:
        units.erase(unit)
        unit_removed.emit(unit)

func get_alive_units() -> Array[Unit]:
    var alive_units: Array[Unit] = []
    for unit in units:
        if unit.current_health > 0:
            alive_units.append(unit)
    return alive_units

func is_defeated() -> bool:
    return get_alive_units().is_empty()

func start_turn() -> void:
    for unit in get_alive_units():
        unit.start_turn()

func end_turn() -> void:
    for unit in get_alive_units():
        unit.end_turn()