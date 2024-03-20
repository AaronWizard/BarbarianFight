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
	## Any cell that is covered by an enemy actor.[br]
	## The source rectangle must contain a single actor.[br]
	## The target rectangle is the rectangle that covers the actor.
	ENEMY,
	## Any cell that is covered by an allied actor.[br]
	## The source rectangle must contain a single actor.[br]
	## The target rectangle is the rectangle that covers the actor.
	ALLY,
	## Any cell that does not contain actor.[br]
	## The target rectangle is 1x1.
	EMPTY,
	## Any cell that can be the origin cell of the actor in the source
	## rectangle.[br]
	## The source rectangle must contain a single actor.[br]
	## The target rectangle is the rectangle that the source actor would cover
	## if positioned at the target cell.
	ENTERABLE
}


## Determines the type of tiles within the visible range that are valid.
@export var target_type := TargetRange.TargetType.ANY


## Gets the target range around [param source_rect].
## [br][br]
## If an actor is in [param source_rect] it is treated as the source actor. This
## is relevant to target types of ENEMY, ALLY, and ENTERABLE.[br]
## It is assumed that the source actor is fully covered by the source rectangle
## and that its origin cell is at the bottom-left corner (see [TileObject]).
func get_target_range(source_rect: Rect2i, map: Map) -> TargetRangeData:
	var full_range := _get_full_range(source_rect)
	var valid_targets := _get_valid_targets(full_range, source_rect, map)
	return TargetRangeData.new(full_range, valid_targets, {}, {})


## Get the base full target range.[br]
## Can be overriden.
func _get_full_range(_source_rect: Rect2i) -> Array[Vector2i]:
	push_warning("TargetRange._get_visible_range not implemented")
	return []


func _get_valid_targets(full_range: Array[Vector2i], source_rect: Rect2i,
		map: Map) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for cell in full_range:
		if _is_valid_target(cell, source_rect, map):
			result.append(cell)
	return result


func _is_valid_target(cell: Vector2i, source_rect: Rect2i, map: Map) -> bool:
	var result := false

	if target_type == TargetType.ANY:
		result = true
	else:
		var source_actor := map.actor_map.get_actor_on_cell(
			TileGeometry.tile_object_origin(source_rect)
		)
		if target_type == TargetType.ENTERABLE:
			result = map.actor_can_enter_cell(source_actor, cell)
		else:
			var actor_on_target := map.actor_map.get_actor_on_cell(cell)
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
