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


## Initializes pathfinding for actors with the given size.
func init_grid_for_actor_size(actor_size: Vector2i) -> void:
	if (actor_size != Vector2i.ONE) and not _grids.has(actor_size):
		var new_grid := _create_grid()
		_grids[actor_size] = new_grid
		_update_other_grids()


## Enables or disables a single cell for pathfinding.
func set_cell_solid(cell: Vector2i, solid: bool) -> void:
	_base_grid.set_point_solid(cell, solid)
	_update_other_grids()


## Enables or disables a rectangle of cells for pathfinding.
func set_rect_solid(rect: Rect2i, solid: bool) -> void:
	_base_grid.fill_solid_region(rect, solid)
	_update_other_grids()


## Finds a path that would move [param start_rect] to a position adjacent to
## [param end_rect]. If no valid path exists the result is empty.
func find_path_between_rects(start_rect: Rect2i, end_rect: Rect2i) \
		-> Array[Vector2i]:
	var result: Array[Vector2i] = []

	# Prevent getting blocked by anything in start_rect itself.
	var start_solid_status := _get_rect_solid_status(start_rect)
	set_rect_solid(start_rect, false)

	var grid := _get_grid(start_rect.size)
	var end_cells := _end_cells(end_rect, start_rect.size, grid)
	for end_cell in end_cells:
		var path := grid.get_id_path(start_rect.position, end_cell)
		if not path.is_empty() \
				and (result.is_empty() or (path.size() < result.size())):
			assert(not path.is_empty())
			result = path

	_set_rect_solid_status(start_solid_status)

	return result


static func _end_cells(end_rect: Rect2i, actor_size: Vector2i,
		grid: AStarGrid2D) -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	var cells := TileGeometry.adjacent_rect_positions(
			end_rect, actor_size)
	for c in cells:
		if grid.is_in_boundsv(c) and not grid.is_point_solid(c):
			result.append(c)

	return result


func _update_other_grids() -> void:
	var region := _base_grid.region

	@warning_ignore("untyped_declaration")
	for k in _grids.keys():
		@warning_ignore("unsafe_cast")
		var actor_size := k as Vector2i
		@warning_ignore("unsafe_cast")
		var grid := _grids[actor_size] as AStarGrid2D

		grid.clear()
		grid.region = region
		grid.update()
		for x in range(region.position.x, region.end.x):
			for y in range(region.position.y, region.end.y):
				var cell := Vector2i(x, y)
				if _base_grid.is_point_solid(cell):
					var block_rect := Rect2i(
						cell - actor_size + Vector2i.ONE,
						actor_size
					)
					grid.fill_solid_region(block_rect, true)
		var bottom_border := Rect2i(
			Vector2i(region.position.x, region.end.y - actor_size.y + 1),
			Vector2i(region.size.x, actor_size.y - 1)
		)
		var right_border := Rect2i(
			Vector2i(region.end.x - actor_size.x + 1, region.position.y),
			Vector2i(actor_size.x - 1, region.size.y)
		)
		grid.fill_solid_region(bottom_border, true)
		grid.fill_solid_region(right_border, true)


func _create_grid() -> AStarGrid2D:
	var result := AStarGrid2D.new()
	result.region = _map_region
	result.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	result.cell_shape = AStarGrid2D.CELL_SHAPE_SQUARE
	result.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	result.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	result.update()
	return result


func _get_grid(actor_size: Vector2i) -> AStarGrid2D:
	var result: AStarGrid2D = null
	if actor_size == Vector2i.ONE:
		result = _base_grid
	else:
		result = _grids[actor_size]
	return result


func _get_rect_solid_status(rect: Rect2i) -> Dictionary:
	var result := {}

	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			var cell := Vector2i(x, y)
			var is_solid := _base_grid.is_point_solid(cell)
			result[cell] = is_solid

	return result


func _set_rect_solid_status(status: Dictionary) -> void:
	@warning_ignore("untyped_declaration")
	for k in status.keys():
		@warning_ignore("unsafe_cast")
		var cell := k as Vector2i
		@warning_ignore("unsafe_cast")
		var is_solid := status[cell] as bool
		_base_grid.set_point_solid(cell, is_solid)

	_update_other_grids()
