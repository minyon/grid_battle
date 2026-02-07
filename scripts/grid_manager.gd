extends Node

# Manages the battle grid for Grid Battle
class_name GridManager
extends Node

# Grid properties
var grid_width: int = 8
var grid_height: int = 8
var cell_size: int = 64
var grid_data: Array[GridCell] = []

# Node references
@onready var grid_container: Node2D = $"../GridContainer"

# Signals
signal grid_initialized()
signal unit_placed(unit: Unit, grid_pos: Vector2i)
signal unit_moved(unit: Unit, old_pos: Vector2i, new_pos: Vector2i)

func _ready() -> void:
    pass

func setup_grid(width: int, height: int, size: int) -> void:
    grid_width = width
    grid_height = height
    cell_size = size
    
    _create_grid_cells()
    _create_visual_grid()
    
    grid_initialized.emit()
    print("Grid initialized: ", width, "x", height)

func _create_grid_cells() -> void:
    grid_data.clear()
    
    for x in range(grid_width):
        for y in range(grid_height):
            var cell: GridCell = GridCell.new()
            cell.grid_position = Vector2i(x, y)
            cell.world_position = Vector2(x * cell_size, y * cell_size)
            grid_data.append(cell)

func _create_visual_grid() -> void:
    if not grid_container:
        return
    
    # Clear existing grid visuals
    for child in grid_container.get_children():
        child.queue_free()
    
    # Create grid tiles
    for cell in grid_data:
        var tile: Sprite2D = Sprite2D.new()
        tile.position = cell.world_position
        tile.texture = _get_grid_tile_texture(cell)
        grid_container.add_child(tile)

func _get_grid_tile_texture(cell: GridCell) -> Texture2D:
    # Return different textures based on cell type
    match cell.cell_type:
        GridCell.CellType.NORMAL:
            return _create_colored_rect(Color.WHITE, cell_size)
        GridCell.CellType.OBSTACLE:
            return _create_colored_rect(Color.DARK_GRAY, cell_size)
        GridCell.CellType.SPAWN_POINT_1:
            return _create_colored_rect(Color.BLUE, cell_size)
        GridCell.CellType.SPAWN_POINT_2:
            return _create_colored_rect(Color.RED, cell_size)
        _:
            return _create_colored_rect(Color.WHITE, cell_size)

func _create_colored_rect(color: Color, size: int) -> Texture2D:
    var image: Image = Image.create(size, size, false, Image.FORMAT_RGB8)
    image.fill(color)
    
    var texture: ImageTexture = ImageTexture.new()
    texture.set_image(image)
    return texture

func get_cell_at(grid_pos: Vector2i) -> GridCell:
    if not _is_valid_grid_position(grid_pos):
        return null
    
    var index: int = grid_pos.y * grid_width + grid_pos.x
    return grid_data[index]

func get_cell_at_world(world_pos: Vector2) -> GridCell:
    var grid_pos: Vector2i = Vector2i(
        int(world_pos.x / cell_size),
        int(world_pos.y / cell_size)
    )
    return get_cell_at(grid_pos)

func _is_valid_grid_position(grid_pos: Vector2i) -> bool:
    return grid_pos.x >= 0 and grid_pos.x < grid_width and \
           grid_pos.y >= 0 and grid_pos.y < grid_height

func place_unit(unit: Unit, grid_pos: Vector2i) -> bool:
    var cell: GridCell = get_cell_at(grid_pos)
    if not cell or cell.is_occupied():
        return false
    
    cell.occupying_unit = unit
    unit.grid_position = grid_pos
    unit.global_position = cell.world_position
    
    unit_placed.emit(unit, grid_pos)
    return true

func move_unit(unit: Unit, new_pos: Vector2i) -> bool:
    var old_cell: GridCell = get_cell_at(unit.grid_position)
    var new_cell: GridCell = get_cell_at(new_pos)
    
    if not new_cell or new_cell.is_occupied():
        return false
    
    if old_cell:
        old_cell.occupying_unit = null
    
    new_cell.occupying_unit = unit
    var old_pos: Vector2i = unit.grid_position
    unit.grid_position = new_pos
    unit.global_position = new_cell.world_position
    
    unit_moved.emit(unit, old_pos, new_pos)
    return true