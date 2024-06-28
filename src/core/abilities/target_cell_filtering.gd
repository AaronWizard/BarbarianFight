class_name TargetCellFiltering

## Class for filtering cells from target ranges and AOEs.


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


## What kind of line of sight is needed between the source and the target cell.
enum LineOfSightType
{
	## No line of sight is needed.
	NONE,
	## No cell in the line of sight blocks vision.
	CAN_SEE,
	## Every cell in the line of sight can be an origin cell for the source
	## actor.
	CAN_MOVE
}


## Get the subset of cells within [param full_range] that are valid.[br]
## [param source_actor] is required if [param target_type] is
## [enum TargetCellFiltering.TargetType.ENEMY],
## [enum TargetCellFiltering.TargetType.ALLY], or
## [enum TargetCellFiltering.TargetType.ENTERABLE]; and if [param losType] is
## [enum TargetCellFiltering.LineOfSightType.CAN_MOVE].[br]
## [param source_cell] and [param source_size] do not have to correspond to
## [param source_actor].
static func get_valid_targets(
		full_range: Array[Vector2i],
		source_cell: Vector2i, source_size: int,
		target_type: TargetType, losType: LineOfSightType,
		source_actor: Actor) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for cell in full_range:
		if _is_valid_target(cell, target_type, source_actor):
			result.append(cell)
	return result


static func _is_valid_target(cell: Vector2i, target_type: TargetType,
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


static func _has_line_of_sight(cell: Vector2i,
		source_cell: Vector2i, source_size: int, losType: LineOfSightType,
		source_actor: Actor) -> bool:
	var result := false
	return result


static func _cell_is_blocked(cell: Vector2i, map: Map,
		losType: LineOfSightType) -> bool:
	var result := false

	match losType:
		LineOfSightType.CAN_SEE:
			pass

	return result
