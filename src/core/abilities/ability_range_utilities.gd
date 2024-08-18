class_name AbilityRangeUtilities

## Methods related to ability target ranges and ares of effect.

## The type of cells in a target/AOE range that can have targets. Determines the
## corresponding target rectangle.
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


## A configuration for whether line-of-sight to a target cell is blocked by
## actors.
enum LOSActorBlocking
{
	## Actors do not block line-of-sight.
	NONE,
	## Any actor blocks line-of-sight.
	ANY,
	## Only enemies block line-of-sight.
	ENEMIES
}


## Checks if there's line-of-sight between [param start_cell] and
## [param target_cell], based on [param is_blocking_cell_func].[br]
## [code]is_blocking_cell_func(cell: Vector2i) -> bool[/code]: Return true if
## the cell is a blocking cell.

## Get the subset of cells within [param full_range] that are visible.[br]
## [code]los_start_cell_func(cell: Vector2i) -> Vector2i[/code]:
## Return the cell to use as the start cell when checking line-of-sight to the
## end cell.[br]
## [code]is_los_blocking_cell_func(cell: Vector2i) -> bool[/code]:
## Return true if the cell blocks line-of-sight to the source actor.
static func get_visible_range(
		full_range: Array[Vector2i],
		los_start_cell_func: Callable, is_los_blocking_cell_func: Callable) \
		-> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for target_cell in full_range:
		@warning_ignore("unsafe_cast")
		var start_cell := los_start_cell_func.call(target_cell) as Vector2i
		if TileGeometry.unblocked_line_exists(
				start_cell, target_cell, is_los_blocking_cell_func):
			result.append(target_cell)
	return result


## Check if [param target_cell] blocks line-of-sight.[br]
## A cell blocks line-of-sight if:
## - It blocks sight[br]
## - It blocks movement and [param blocks_movement] is true
## - An actor other than the source actor is covering it, depending on
##   [param actor_blocking][br]
## - It blocks ranged abilities and [param ignore_range_blocking] is false[br]
static func is_los_blocking_cell(
		cell: Vector2i,
		source_actor: Actor,
		blocks_movement: bool,
		actor_blocking: LOSActorBlocking,
		ignore_range_blocking: bool) \
		-> bool:
	var result := source_actor.map.terrain.blocks_sight(cell)

	if blocks_movement:
		result = result and not source_actor.map.actor_can_enter_cell(
				source_actor, cell)

	if actor_blocking != LOSActorBlocking.NONE:
		var other_actor := source_actor.map.actor_map.get_actor_on_cell(cell)
		if other_actor != source_actor:
			match actor_blocking:
				LOSActorBlocking.ANY:
					result = true
				LOSActorBlocking.ENEMIES:
					result = result and other_actor.is_hostile(source_actor)

	if not ignore_range_blocking:
		result = result and source_actor.map.terrain.blocks_ranged(cell)

	return result


## Get a list of valid target rectangles within [param target_range] based on a
## given target type.
static func get_targets_in_range(target_range: Array[Vector2i],
		target_type: TargetType, source_actor: Actor) -> Array[Rect2i]:
	var targets := {} # Avoid duplicates
	for cell in target_range:
		if _cell_is_target(cell, target_type, source_actor):
			var target := _target_rectangle(cell, target_type, source_actor)
			if not targets.has(cell) or (target.size > targets[cell].size):
				targets[cell] = target
	var result: Array[Rect2i] = []
	result.assign(targets.values())

	return result

static func extend_visible_range_by_size(visible_range: Array[Vector2i],
		size: int) -> void:
	var extra_cells_dict := {}
	for visible_cell in visible_range:
		var v_rect := Rect2i(visible_cell, Vector2i(size, size))
		for cell in TileGeometry.cells_in_rect(v_rect):
			extra_cells_dict[cell] = true

	var extra_cells: Array[Vector2i] = []
	extra_cells.assign(extra_cells_dict.keys())
	for cell in extra_cells:
		if cell not in visible_range:
			visible_range.append(cell)


static func _cell_is_target(cell: Vector2i, target_type: TargetType,
		source_actor: Actor) -> bool:
	var result := false

	match target_type:
		TargetType.ANY:
			result = true
		TargetType.ANY_ACTOR:
			if not source_actor:
				push_error("Source actor expected")
			else:
				result = source_actor.map.actor_map.get_actor_on_cell(cell) \
						!= null
		TargetType.ENEMY:
			if not source_actor:
				push_error("Source actor expected")
			else:
				var actor_on_target \
						:= source_actor.map.actor_map.get_actor_on_cell(cell)
				result = actor_on_target \
						and actor_on_target.is_hostile(source_actor)
		TargetType.ALLY:
			if not source_actor:
				push_error("Source actor expected")
			else:
				var actor_on_target \
						:= source_actor.map.actor_map.get_actor_on_cell(cell)
				result = actor_on_target \
						and not actor_on_target.is_hostile(source_actor)

		TargetType.EMPTY:
			result = source_actor.map.actor_map.get_actor_on_cell(cell) == null
		TargetType.ENTERABLE:
			if not source_actor:
				push_error("Source actor expected")
			else:
				result = source_actor.map.actor_can_enter_cell(
						source_actor, cell)

	return result


static func _target_rectangle(target_cell: Vector2i, target_type: TargetType,
		source_actor: Actor) -> Rect2i:
	var result := Rect2i(target_cell, Vector2i.ONE)
	match target_type:
		TargetType.ANY_ACTOR, TargetType.ENEMY, TargetType.ALLY:
			var other_actor := source_actor.map.actor_map.get_actor_on_cell(
					target_cell)
			result.position = other_actor.origin_cell
			result.size = Vector2i(other_actor.cell_size, other_actor.cell_size)
		TargetType.ENTERABLE:
			result.size = Vector2i(
					source_actor.cell_size, source_actor.cell_size)
	return result
