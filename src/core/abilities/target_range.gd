class_name TargetRange
extends Resource

## Class for getting the target range of an ability.

## The type of target cells that are valid.[br]
## Also affects the corresponding target rectangle.
enum TargetType
{
	## Any cell in range.[br]
	## The target rectangle is 1x1.
	ANY,
	## Any cell that is covered by an actor.[br]
	## The target rectangle is the rectangle that covers the actor.
	ANY_ACTOR,
	## Any cell that is covered by an actor that is an enemy of the source
	## actor.[br]
	## The source rectangle must contain a single actor.[br]
	## The target rectangle is the rectangle that covers the actor.
	ENEMY,
	## Any cell that is covered by an actor allied to the source actor.[br]
	## The source rectangle must contain a single actor.[br]
	## The target rectangle is the rectangle that covers the actor.
	ALLY,
	## Any cell that does not contain actor.[br]
	## The target rectangle is 1x1.
	EMPTY,
	## Any cell that can be the origin cell of the source actor.[br]
	## The target rectangle is the rectangle that the source actor would cover
	## if positioned at the target cell.
	ENTERABLE
}


## Determines the type of tiles within the visible range that are valid.
@export var target_type := TargetRange.TargetType.ANY


## Gets the cells that can be targeted from [param source_cell] by
## [param source_actor].
## [br][br]
## [param source_actor] is relevant to the target types
## [enum TargetRange.TargetType.ENEMY], [enum TargetRange.TargetType.ALLY], and
## [enum TargetRange.TargetType.ENTERABLE].[br]
## If [param source_size] is greater than 1, the ability source is treated as a
## square with [param source_cell] as the [b]top left[/b] corner (see
## [TileObject]). Assumed to be the cell size of [param source_actor].[br]
## [param source_cell] does not have to be the origin cell of
## [param source_actor].
func get_target_range(source_cell: Vector2i, source_size: int, \
		source_actor: Actor) -> TargetRangeData:
	var full_range := _get_full_range(source_cell, source_size)
	var valid_targets := _get_valid_targets(full_range, source_actor)
	return TargetRangeData.new(full_range, valid_targets, {}, {})


## Get the base full target range.[br]
## Can be overriden.
func _get_full_range(_source_cell: Vector2i, _source_size: int) \
		-> Array[Vector2i]:
	push_warning("TargetRange._get_full_range not implemented")
	return []


func _get_valid_targets(full_range: Array[Vector2i], source_actor: Actor) \
		-> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for cell in full_range:
		if _is_valid_target(cell, source_actor):
			result.append(cell)
	return result


func _is_valid_target(cell: Vector2i, source_actor: Actor) -> bool:
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
