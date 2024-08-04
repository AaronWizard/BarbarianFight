class_name TargetRange
extends Resource

## Class for getting the target range of an actor's ability.

## Class for getting the target range of an actor's ability. Returns a
## [TargetingData] object containing the set of possible targets.


## Gets the targets for an abilith whose source is [param source_actor].
func get_target_range(source_actor: Actor) -> TargetingData:
	var full_range := _get_full_range(source_actor.square)
	var visible_range := _get_visible_range(full_range, source_actor)
	var targets := _get_targets(visible_range, source_actor)

	_range_post_processing(visible_range, source_actor.square)

	return TargetingData.new(visible_range, targets)


## Get the set of cells representing the full unfiltered target range.[br]
## Can be overriden.
func _get_full_range(_source: Square) -> Array[Vector2i]:
	push_warning("TargetRange._get_full_range not implemented")
	return []


## Get the cell to use as the start when checking line-of-sight to
## [param cell].[br]
## Defaults to the centermost cell within [param ability_source] that is closest
## to [param cell].[br]
## Can be overriden.
func _los_start_cell(cell: Vector2i, ability_source: Square) -> Vector2i:
	return TileGeometry.rect_center_cell_closest_to_target(
			ability_source.rect, cell)


## Returns true if [param cell] blocks line-of-sight for ability targeting.[br]
## Default implementation checks if the cell blocks sight and ranged abilities.
## [br]
## Can be overriden.
func _cell_blocks_los(cell: Vector2i, source_actor: Actor) -> bool:
	return source_actor.map.terrain.blocks_sight(cell) \
			and source_actor.map.terrain.blocks_ranged(cell)


## Returns the target if any that covers [param cell].[br]
## The position of the target may be different from [param cell].[br]
## Can be overriden.
func _target_at_cell(_cell: Vector2i, _source_actor: Actor) -> Square:
	push_warning("TargetRange._target_at_cell not implemented")
	return null


## Post-processing of visible range.[br]
## Can be overriden.
func _range_post_processing(_visible_range: Array[Vector2i],
		_source: Square) -> void:
	pass


func _get_visible_range(full_range: Array[Vector2i], source_actor: Actor) \
		-> Array[Vector2i]:
	var los_start_cell_func := func (cell: Vector2i) -> Vector2i:
		return _los_start_cell(cell, source_actor.square)
	var block_check_func := func(cell: Vector2i) -> bool:
		return _cell_blocks_los(cell, source_actor)

	return AbilityRangeUtilities.get_visible_range(
		full_range, los_start_cell_func,  block_check_func
	)


func _get_targets(visible_range: Array[Vector2i], source_actor: Actor) \
		-> Array[Square]:
	var target_at_cell_func := func (cell: Vector2i) -> Square:
		return _target_at_cell(cell, source_actor)

	return AbilityRangeUtilities.get_targets_in_range(
			visible_range, target_at_cell_func)
