extends CharacterBody2D

# Base unit class for Grid Battle
class_name Unit
extends CharacterBody2D

# Unit properties
@export var unit_name: String = "Unit"
@export var max_health: int = 100
@export var movement_range: int = 3
@export var attack_range: int = 1
@export var attack_damage: int = 25

# Current state
var current_health: int
var grid_position: Vector2i = Vector2i.ZERO
var owner_player: Player = null
var has_moved_this_turn: bool = false
var has_attacked_this_turn: bool = false

# Node references
@onready var sprite: Sprite2D = $Sprite2D
@onready var health_bar: ProgressBar = $HealthBar
@onready var selection_indicator: Sprite2D = $SelectionIndicator

# Signals
signal health_changed(current: int, maximum: int)
signal unit_died(unit: Unit)
signal turn_completed(unit: Unit)

func _ready() -> void:
    current_health = max_health
    _update_health_bar()
    _hide_selection()

func setup_unit(player: Player, start_pos: Vector2i) -> void:
    owner_player = player
    grid_position = start_pos
    
    # Set unit color based on player
    if sprite:
        sprite.modulate = player.player_color

func take_damage(damage: int) -> void:
    current_health = max(0, current_health - damage)
    _update_health_bar()
    
    health_changed.emit(current_health, max_health)
    
    if current_health <= 0:
        _die()

func heal(amount: int) -> void:
    current_health = min(max_health, current_health + amount)
    _update_health_bar()
    health_changed.emit(current_health, max_health)

func _update_health_bar() -> void:
    if health_bar:
        health_bar.value = float(current_health) / float(max_health)

func _die() -> void:
    unit_died.emit(self)
    queue_free()

func start_turn() -> void:
    has_moved_this_turn = false
    has_attacked_this_turn = false
    _show_selection()

func end_turn() -> void:
    has_moved_this_turn = false
    has_attacked_this_turn = false
    _hide_selection()
    turn_completed.emit(self)

func can_move() -> bool:
    return not has_moved_this_turn

func can_attack() -> bool:
    return not has_attacked_this_turn

func _show_selection() -> void:
    if selection_indicator:
        selection_indicator.visible = true

func _hide_selection() -> void:
    if selection_indicator:
        selection_indicator.visible = false

func is_enemy_with(other_unit: Unit) -> bool:
    return owner_player != other_unit.owner_player