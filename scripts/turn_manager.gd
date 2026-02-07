extends Node

# Manages turn-based gameplay for Grid Battle
class_name TurnManager
extends Node

# Turn state
enum TurnPhase { PLAYER1_TURN, PLAYER2_TURN, GAME_OVER }
var current_phase: TurnPhase = TurnPhase.PLAYER1_TURN
var current_turn_number: int = 1

# Players
var player1: Player
var player2: Player
var current_player: Player

# Node references
@onready var game_controller: GridBattleGame = $".."

# Signals
signal turn_started(player: Player, turn_number: int)
signal turn_ended(player: Player)
signal game_started()
signal game_ended(winner: Player)

func _ready() -> void:
    _initialize_players()

func _initialize_players() -> void:
    player1 = Player.new("Player 1", 1, Color.BLUE, false)
    player2 = Player.new("Player 2", 2, Color.RED, true)  # AI player
    
    # Connect player signals
    player1.unit_removed.connect(_on_unit_removed)
    player2.unit_removed.connect(_on_unit_removed)

func start_game() -> void:
    current_phase = TurnPhase.PLAYER1_TURN
    current_player = player1
    current_turn_number = 1
    
    game_started.emit()
    _start_turn()

func _start_turn() -> void:
    if current_phase == TurnPhase.GAME_OVER:
        return
    
    turn_started.emit(current_player, current_turn_number)
    current_player.start_turn()
    
    # If AI player, automatically execute turn
    if current_player.is_ai:
        _execute_ai_turn()

func end_turn() -> void:
    turn_ended.emit(current_player)
    current_player.end_turn()
    
    # Check for victory conditions
    if _check_victory_conditions():
        return
    
    # Switch to next player
    _switch_player()

func _switch_player() -> void:
    match current_phase:
        TurnPhase.PLAYER1_TURN:
            current_phase = TurnPhase.PLAYER2_TURN
            current_player = player2
        TurnPhase.PLAYER2_TURN:
            current_phase = TurnPhase.PLAYER1_TURN
            current_player = player1
            current_turn_number += 1
        TurnPhase.GAME_OVER:
            return
    
    _start_turn()

func _execute_ai_turn() -> void:
    # Simple AI: random actions for each unit
    await get_tree().create_timer(1.0).timeout  # Thinking delay
    
    var alive_units: Array[Unit] = current_player.get_alive_units()
    for unit in alive_units:
        if unit.can_move():
            _ai_move_unit(unit)
            await get_tree().create_timer(0.5).timeout
        
        if unit.can_attack():
            _ai_attack_with_unit(unit)
            await get_tree().create_timer(0.5).timeout
    
    # End AI turn after a short delay
    await get_tree().create_timer(1.0).timeout
    end_turn()

func _ai_move_unit(unit: Unit) -> void:
    # Simple AI: move to random adjacent position
    var grid_manager: GridManager = game_controller.grid_manager
    var possible_moves: Array[Vector2i] = _get_possible_moves(unit)
    
    if not possible_moves.is_empty():
        var random_move: Vector2i = possible_moves.pick_random()
        grid_manager.move_unit(unit, random_move)

func _ai_attack_with_unit(unit: Unit) -> void:
    # Simple AI: attack nearest enemy if in range
    var grid_manager: GridManager = game_controller.grid_manager
    var enemies: Array[Unit] = _get_enemies_in_range(unit)
    
    if not enemies.is_empty():
        var target: Unit = enemies.pick_random()
        target.take_damage(unit.attack_damage)

func _get_possible_moves(unit: Unit) -> Array[Vector2i]:
    var moves: Array[Vector2i] = []
    var grid_manager: GridManager = game_controller.grid_manager
    
    for x in range(-unit.movement_range, unit.movement_range + 1):
        for y in range(-unit.movement_range, unit.movement_range + 1):
            if abs(x) + abs(y) <= unit.movement_range:  # Manhattan distance
                var new_pos: Vector2i = unit.grid_position + Vector2i(x, y)
                var cell: GridCell = grid_manager.get_cell_at(new_pos)
                if cell and cell.can_enter(unit):
                    moves.append(new_pos)
    
    return moves

func _get_enemies_in_range(unit: Unit) -> Array[Unit]:
    var enemies: Array[Unit] = []
    var grid_manager: GridManager = game_controller.grid_manager
    
    for x in range(-unit.attack_range, unit.attack_range + 1):
        for y in range(-unit.attack_range, unit.attack_range + 1):
            if abs(x) + abs(y) <= unit.attack_range:  # Manhattan distance
                var check_pos: Vector2i = unit.grid_position + Vector2i(x, y)
                var cell: GridCell = grid_manager.get_cell_at(check_pos)
                if cell and cell.occupying_unit and unit.is_enemy_with(cell.occupying_unit):
                    enemies.append(cell.occupying_unit)
    
    return enemies

func _check_victory_conditions() -> bool:
    if player1.is_defeated():
        current_phase = TurnPhase.GAME_OVER
        game_ended.emit(player2)
        return true
    elif player2.is_defeated():
        current_phase = TurnPhase.GAME_OVER
        game_ended.emit(player1)
        return true
    
    return false

func _on_unit_removed(unit: Unit) -> void:
    # Check victory conditions whenever a unit is removed
    _check_victory_conditions()