class_name Pathfinder

## A class for finding paths on a map.
##
## A class for finding paths on a [Map] for [Actor] objects. Handles actors with
## different sizes.

var _map_region: Rect2i

var _base_grid: AStarGrid2D # Used by 1x1 actors
# Key = Vector2i, Value =  AStarGrid2D, used by actors bigger than 1x1
var _grids := {}


## Initializes the Pathfinder with the bounds of the map
func _init(map_region: Rect2i) -> void:
	_map_region = map_region
	_base_grid = _create_grid()


func init_grid_for_actor_size(actor_size: Vector2i) -> void:
	if (actor_size != Vector2i.ONE) and not _grids.has(actor_size):
		var new_grid := _create_grid()
		for x in range(_map_region.position.x, _map_region.end.x):
			for y in range(_map_region.position.y, _map_region.end.y):
				var cell := Vector2i(x, y)
				if _base_grid.is_point_solid(cell):
					Pathfinder._block_rect(
							Rect2i(cell, Vector2i.ONE), new_grid, actor_size)
		_grids[actor_size] = new_grid


## Enables or disables a single cell for pathfinding.
func set_cell_solid(cell: Vector2i, solid: bool) -> void:
	set_rect_solid(Rect2i(cell, Vector2i.ONE), solid)


## Enables or disables a rectangle of cells for pathfinding.
func set_rect_solid(rect: Rect2i, solid: bool) -> void:
	_base_grid.fill_solid_region(rect, solid)
	@warning_ignore("untyped_declaration")
	for a in _grids.keys():
		@warning_ignore("unsafe_cast")
		var actor_size := a as Vector2i
		@warning_ignore("unsafe_cast")
		var other_grid := _grids[actor_size] as AStarGrid2D
		if solid:
			Pathfinder._block_rect(rect, other_grid, actor_size)
		else:
			_clear_rect(rect, other_grid, actor_size)


## Finds the shortest path from [param start_cell] to any cell adjacent to
## [param end_rect], using an actor whose size is [param actor_size]. If no
## valid path exists the result is empty.
func find_path(start_cell: Vector2i, end_rect: Rect2i, actor_size: Vector2i) \
		-> Array[Vector2i]:
	var grid: AStarGrid2D
	if actor_size == Vector2i.ONE:
		grid = _base_grid
	else:
		grid = _grids[actor_size]

	var end_cell := end_rect.position

	return grid.get_id_path(start_cell, end_cell)


static func _rect_to_update(rect: Rect2i, actor_size: Vector2i) -> Rect2i:
	return Rect2i(
		rect.position - actor_size + Vector2i.ONE,
		rect.size + actor_size - Vector2i.ONE
	)


static func _block_rect(rect: Rect2i, grid: AStarGrid2D, actor_size: Vector2i) \
		-> void:
	var rect_to_update := Pathfinder._rect_to_update(rect, actor_size)
	grid.fill_solid_region(rect_to_update, true)


func _clear_rect(rect: Rect2i, grid: AStarGrid2D, actor_size: Vector2i) -> void:
	var rect_to_update := Pathfinder._rect_to_update(rect, actor_size)

	grid.fill_solid_region(rect_to_update, false)

	var still_blocked: Array[Vector2i] = []
	for x in range(rect_to_update.position.x, rect_to_update.end.x):
		for y in range(rect_to_update.position.y, rect_to_update.end.y):
			var cell := Vector2i(x, y)
			if _base_grid.is_point_solid(cell):
				still_blocked.append(cell)

	for cell in still_blocked:
		Pathfinder._block_rect(
				Rect2i(cell, Vector2i.ONE), grid, actor_size)


func _create_grid() -> AStarGrid2D:
	var result := AStarGrid2D.new()
	result.region = _map_region
	result.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	result.cell_shape = AStarGrid2D.CELL_SHAPE_SQUARE
	result.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	result.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	result.update()
	return result
