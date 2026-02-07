extends Node2D

# Main game controller for Grid Battle
class_name GridBattleGame
extends Node2D

# Game state
enum GameState { MENU, PLAYING, PAUSED, VICTORY, DEFEAT }
var current_state: GameState = GameState.MENU

# Grid configuration
@export var grid_width: int = 8
@export var grid_height: int = 8
@export var cell_size: int = 64

# Player references
@onready var grid_manager: GridManager = $GridManager
@onready var turn_manager: TurnManager = $TurnManager
@onready var ui_manager: UIManager = $UIManager

func _ready() -> void:
    print("Grid Battle initialized")
    _initialize_game()

func _initialize_game() -> void:
    # Initialize grid
    if grid_manager:
        grid_manager.setup_grid(grid_width, grid_height, cell_size)
    
    # Connect signals
    if turn_manager:
        turn_manager.turn_ended.connect(_on_turn_ended)
    
    # Start game
    start_game()

func start_game() -> void:
    current_state = GameState.PLAYING
    print("Game started!")

func _on_turn_ended(player: Player) -> void:
    print("Turn ended for player: ", player.name)

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        toggle_pause()

func toggle_pause() -> void:
    if current_state == GameState.PLAYING:
        current_state = GameState.PAUSED
        get_tree().paused = true
    elif current_state == GameState.PAUSED:
        current_state = GameState.PLAYING
        get_tree().paused = false