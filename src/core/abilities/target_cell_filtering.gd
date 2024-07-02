class_name TargetCellFiltering

## Class for filtering cells from target ranges and AOEs.


## What cell within a source square is used as the start of the line of sight to
## a target cell.
enum LOSSourceOrigin
{
	## The center cell if the source square has odd dimensions, or the closest
	## of the four center cells to the target cell if the source square has
	## even dimensions.
	CENTER,
	## The top left cell of the source square.
	TOP_LEFT
}


## The type of target cells that are valid.
enum TargetType
{
	## Any cell.
	ANY,
	## Any cell that is covered by an actor.
	ANY_ACTOR,
	## Any cell that is covered by an actor that is an enemy of the source
	## actor.
	ENEMY,
	## Any cell that is covered by an actor allied to the source actor.
	ALLY,
	## Any cell that does not contain actor.
	EMPTY,
	## Any cell that can be the origin cell of the source actor.
	ENTERABLE
}


## Get the subset of cells within [param cells] that have line of sight with the
## source square represented by [param source_cell] and [param source_size].[br]
## [param los_type] determines what cells block line of sight.[br]
## [param los_origin] determines what cell within the source square is the start
## cell of the line of sight.
static func get_cells_in_line_of_sight(
		cells: Array[Vector2i],
		source_cell: Vector2i, source_size: int,
		los_origin: LOSSourceOrigin,
		source_actor: Actor) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for target_cell in cells:
		var start_cell := _get_los_start_cell(
				target_cell, source_cell, source_size, los_origin)
		if _has_line_of_sight(target_cell, start_cell, source_actor.map):
			result.append(target_cell)
	return result


## Get the subset of cells within [param cells] that match the given target
## type.[br]
## [param source_actor] is required if [param target_type] is
## [enum TargetCellFiltering.TargetType.ENEMY],
## [enum TargetCellFiltering.TargetType.ALLY], or
## [enum TargetCellFiltering.TargetType.ENTERABLE].[br]
static func get_cells_with_target_type(
		cells: Array[Vector2i],
		target_type: TargetType,
		source_actor: Actor) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for cell in cells:
		if _cell_is_of_target_type(cell, target_type, source_actor):
			result.append(cell)
	return result


static func _get_los_start_cell(
		target_cell: Vector2i,
		source_cell: Vector2i, source_size: int,
		los_origin: LOSSourceOrigin) -> Vector2i:
	var result := source_cell

	if los_origin == LOSSourceOrigin.CENTER:
		@warning_ignore("integer_division")
		var half_size := source_size / 2

		if source_size % 2 != 0:
			result = source_cell + Vector2i(half_size, half_size)
		else:
			var start_cells := [
				source_cell + Vector2i(half_size, half_size),
				source_cell + Vector2i(half_size, half_size) - Vector2i(1, 1),
				source_cell + Vector2i(half_size, half_size) - Vector2i(1, 0),
				source_cell + Vector2i(half_size, half_size) - Vector2i(0, 1)
			]
			result = TileGeometry.closest_cell_to_target(
					start_cells, target_cell)
	else:
		assert(los_origin == LOSSourceOrigin.TOP_LEFT)

	return result


static func _has_line_of_sight(target_cell: Vector2i, start_cell: Vector2i,
		map: Map) -> bool:
	var block_check_func \
			:= func (cell: Vector2i) -> bool: return _cell_blocks_los(cell, map)
	var unblocked_line := TileGeometry.unblocked_line(
			start_cell, target_cell, block_check_func)
	var end_cell := unblocked_line[unblocked_line.size() - 1]

	var result := end_cell == target_cell
	if result:
		result = not (block_check_func.call(end_cell) as bool)

	return result


static func _cell_blocks_los(cell: Vector2i, map: Map) -> bool:
	var result := map.terrain.blocks_sight(cell) \
			or map.terrain.blocks_ranged(cell)
	return result


static func _cell_is_of_target_type(cell: Vector2i, target_type: TargetType,
		source_actor: Actor) -> bool:
	var result := false

	if not source_actor and ( \
			target_type in [
				TargetType.ENTERABLE, TargetType.ENEMY, TargetType.ALLY
			]):
		push_error("Source actor expected")
		return false

	if target_type == TargetType.ANY:
		result = true
	else:
		if target_type == TargetType.ENTERABLE:
			result = source_actor.map.actor_can_enter_cell(source_actor, cell)
		else:
			var actor_on_target \
					:= source_actor.map.actor_map.get_actor_on_cell(cell)
			if actor_on_target:
				match target_type:
					TargetType.ENEMY:
						result = actor_on_target.is_hostile(source_actor)
					TargetType.ALLY:
						result = not actor_on_target.is_hostile(source_actor)
					TargetType.ANY_ACTOR:
						result = true
			else:
				result = target_type == TargetType.EMPTY

	return result
