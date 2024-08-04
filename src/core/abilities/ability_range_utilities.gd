class_name AbilityRangeUtilities

## Methods related to ability target ranges and ares of effect.

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


## Get the subset of cells within [param full_range] that are visible.[br]
## [code]los_start_cell_func(cell: Vector2i) -> Vector2i[/code]:
## Return the cell to use as the start cell when checking line-of-sight to the
## end cell.[br]
## [code]block_check_func(cell: Vector2i) -> bool[/code]:
## Return true if the cell blocks line-of-sight to the source actor.
static func get_visible_range(
		full_range: Array[Vector2i],
		los_start_cell_func: Callable, block_check_func: Callable) \
		-> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for target_cell in full_range:
		var start_cell := los_start_cell_func.call(target_cell) as Vector2i
		if _has_line_of_sight(target_cell, start_cell, block_check_func):
			result.append(target_cell)
	return result


## Get a list of valid target squares within [param visible_range].[br]
## [code]target_at_cell(cell: Vector2i) -> Square[/code]: Returns a square that
## covers the cell. The square's position may be different from the cell.
static func get_targets_in_range(visible_range: Array[Vector2i],
		target_at_cell_func: Callable) -> Array[Square]:
	var targets := {} # Avoid duplicates
	for cell in visible_range:
		var target := target_at_cell_func.call(cell) as Square
		if target and ( \
			not targets.has(cell) or (target.size > targets[cell].size) \
		):
			targets[cell] = target

	var result: Array[Square] = []
	result.assign(targets.values())

	return result


## Get a target at [param cell] based on [param target_type].
static func target_at_cell(cell: Vector2i, target_type: TargetType,
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


static func _has_line_of_sight(
		target_cell: Vector2i,
		start_cell: Vector2i,
		block_check_func: Callable) -> bool:
	var unblocked_line := TileGeometry.unblocked_line(
			start_cell, target_cell, block_check_func)
	var end_cell := unblocked_line[unblocked_line.size() - 1]

	var result := end_cell == target_cell
	if result:
		result = not (block_check_func.call(end_cell) as bool)

	return result
