class_name TargetCellFiltering

## Methods for filtering cells and getting targets from target ranges and AOEs.


## What cell within a source square is used as the start of the line of sight to
## a cell inside a target range.
enum LOSSourceOrigin
{
	## The center cell if the source square has odd dimensions, or the closest
	## of the four center cells to the target cell if the source square has
	## even dimensions.
	CENTER,
	## The top left cell of the source square.
	TOP_LEFT
}


## The type of cells in a target/AOE range that can have targets. Determines the
## corresponding target
## square.
enum TargetType
{
	## Any cell.[br]
	## The target square is 1x1 and positioned on this cell.
	ANY,
	## Any cell that is covered by an actor.[br]
	## The target square matches the size and position of the actor.
	ANY_ACTOR,
	## Any cell that is covered by an actor that is an enemy of the source
	## actor.[br]
	## The target square matches the size and position of the actor.
	ENEMY,
	## Any cell that is covered by an actor allied to the source actor.[br]
	## The target square matches the size and position of the actor.
	ALLY,
	## Any cell that does not contain an actor.[br]
	## The target square is 1x1 and positioned on this cell.
	EMPTY,
	## Any cell that can be the origin cell of the source actor.[br]
	## The target square is the size of the source actor and positioned on this
	## cell.
	ENTERABLE
}


## Get the subset of cells within [param cells] that have line of sight with
## [param source].[br]
## [param los_origin] determines what cell within the source square is the start
## cell of the line of sight.
static func get_cells_in_line_of_sight(
		cells: Array[Vector2i],
		source: Square,
		los_origin: LOSSourceOrigin,
		map: Map) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for target_cell in cells:
		var start_cell := _get_los_start_cell(target_cell, source, los_origin)
		if _has_line_of_sight(target_cell, start_cell, map):
			result.append(target_cell)
	return result


## Get a list of valid target squares within [param visible_range] based on
## [param target_type].[br]
## [param source_actor] is required if [param target_type] is
## [enum TargetCellFiltering.TargetType.ENEMY],
## [enum TargetCellFiltering.TargetType.ALLY], or
## [enum TargetCellFiltering.TargetType.ENTERABLE].
static func get_targets_in_range(
		visible_range: Array[Vector2i],
		target_type: TargetType,
		source_actor: Actor) -> Array[Square]:
	var result: Array[Square] = []

	var targets := {} # Avoid duplicates
	for cell in visible_range:
		var target := _target_at_cell(cell, target_type, source_actor)
		if target:
			targets[target] = true
	result.assign(targets.keys())
	return result


static func extend_visible_range_by_size(visible_range: Array[Vector2i],
		size: int) -> void:
	var extra_cells_dict := {}
	for visible_cell in visible_range:
		var v_square := Square.new(visible_cell, size)
		for cell in TileGeometry.cells_in_rect(v_square.rect):
			extra_cells_dict[cell] = true

	var extra_cells: Array[Vector2i] = []
	extra_cells.assign(extra_cells_dict.keys())
	for cell in extra_cells:
		if cell not in visible_range:
			visible_range.append(cell)


static func _get_los_start_cell(
		target_cell: Vector2i, source: Square,
		los_origin: LOSSourceOrigin) -> Vector2i:
	var result := source.position

	if los_origin == LOSSourceOrigin.CENTER:
		@warning_ignore("integer_division")
		var half_size := source.size / 2
		var center_cell := source.position + Vector2i(half_size, half_size)

		if source.size % 2 != 0:
			result = center_cell
		else:
			var start_cells: Array[Vector2i] = [
				center_cell,
				center_cell - Vector2i(1, 1),
				center_cell - Vector2i(1, 0),
				center_cell - Vector2i(0, 1)
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


static func _target_at_cell(cell: Vector2i, target_type: TargetType,
		source_actor: Actor) -> Square:
	var result: Square = null

	match target_type:
		TargetType.ANY:
			result = Square.new(cell, 1)
		TargetType.ANY_ACTOR:
			if not source_actor:
				push_error("Source actor expected")
			else:
				var actor_on_target \
						:= source_actor.map.actor_map.get_actor_on_cell(cell)
				if actor_on_target:
					result = actor_on_target.square
		TargetType.ENEMY:
			if not source_actor:
				push_error("Source actor expected")
			else:
				var actor_on_target \
						:= source_actor.map.actor_map.get_actor_on_cell(cell)
				if actor_on_target \
						and actor_on_target.is_hostile(source_actor):
					result = actor_on_target.square
		TargetType.ALLY:
			if not source_actor:
				push_error("Source actor expected")
			else:
				var actor_on_target \
						:= source_actor.map.actor_map.get_actor_on_cell(cell)
				if actor_on_target \
						and not actor_on_target.is_hostile(source_actor):
					result = actor_on_target.square
		TargetType.EMPTY:
			if not source_actor.map.actor_map.get_actor_on_cell(cell):
				result = Square.new(cell, 1)
		TargetType.ENTERABLE:
			if not source_actor:
				push_error("Source actor expected")
			elif source_actor.map.actor_can_enter_cell(source_actor, cell):
				result = Square.new(cell, source_actor.cell_size)

	return result
