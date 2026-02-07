extends CanvasLayer

# Manages UI for Grid Battle
class_name UIManager
extends CanvasLayer

# UI Node references
@onready var turn_label: Label = $TurnLabel
@onready var health_label: Label = $HealthLabel
@onready var action_button: Button = $ActionButton
@onready var end_turn_button: Button = $EndTurnButton
@onready var victory_panel: Panel = $VictoryPanel
@onready var defeat_panel: Panel = $DefeatPanel

# Game references
@onready var game_controller: GridBattleGame = $".."
@onready var turn_manager: TurnManager = game_controller.turn_manager

func _ready() -> void:
    _connect_signals()
    _update_ui()

func _connect_signals() -> void:
    if turn_manager:
        turn_manager.turn_started.connect(_on_turn_started)
        turn_manager.turn_ended.connect(_on_turn_ended)
        turn_manager.game_ended.connect(_on_game_ended)
    
    if end_turn_button:
        end_turn_button.pressed.connect(_on_end_turn_pressed)

func _on_turn_started(player: Player, turn_number: int) -> void:
    _update_turn_display(player, turn_number)
    _update_action_button(player)

func _on_turn_ended(player: Player) -> void:
    pass

func _on_game_ended(winner: Player) -> void:
    if winner == turn_manager.player1:
        _show_victory()
    else:
        _show_defeat()

func _on_end_turn_pressed() -> void:
    if turn_manager:
        turn_manager.end_turn()

func _update_turn_display(player: Player, turn_number: int) -> void:
    if turn_label:
        turn_label.text = "Turn %d - %s" % [turn_number, player.player_name]

func _update_action_button(player: Player) -> void:
    if action_button:
        if player.is_ai:
            action_button.text = "AI Thinking..."
            action_button.disabled = true
        else:
            action_button.text = "Your Turn"
            action_button.disabled = false

func _update_ui() -> void:
    _update_turn_display(turn_manager.current_player, turn_manager.current_turn_number)
    _update_action_button(turn_manager.current_player)

func _show_victory() -> void:
    if victory_panel:
        victory_panel.visible = true

func _show_defeat() -> void:
    if defeat_panel:
        defeat_panel.visible = true

func update_unit_health_display(unit: Unit) -> void:
    if health_label:
        health_label.text = "%s HP: %d/%d" % [unit.unit_name, unit.current_health, unit.max_health]