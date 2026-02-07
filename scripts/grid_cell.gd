extends RefCounted

# Represents a single cell in the battle grid
class_name GridCell
extends RefCounted

# Cell types
enum CellType { NORMAL, OBSTACLE, SPAWN_POINT_1, SPAWN_POINT_2 }

# Properties
var grid_position: Vector2i
var world_position: Vector2
var cell_type: CellType = CellType.NORMAL
var occupying_unit: Unit = null

# Constructor
func _init():
    pass

# Check if cell is occupied
func is_occupied() -> bool:
    return occupying_unit != null

# Check if unit can move to this cell
func can_enter(unit: Unit) -> bool:
    if is_occupied() and occupying_unit != unit:
        return false
    
    match cell_type:
        CellType.OBSTACLE:
            return false
        CellType.NORMAL, CellType.SPAWN_POINT_1, CellType.SPAWN_POINT_2:
            return true
        _:
            return false

# Get movement cost for this cell
func get_movement_cost() -> int:
    match cell_type:
        CellType.NORMAL:
            return 1
        CellType.OBSTACLE:
            return 999  # Cannot pass
        CellType.SPAWN_POINT_1, CellType.SPAWN_POINT_2:
            return 1
        _:
            return 1