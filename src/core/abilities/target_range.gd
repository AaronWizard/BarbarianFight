class_name TargetRange
extends Resource

## Class for getting the target range of an actor's ability.

## Class for getting the target range of an actor's ability. Returns a
## [TargetingData] object containing the set of possible targets.


## The type of cells within the full range that are valid.
@export var target_type := TargetCellFiltering.TargetType.ANY

@export var los_origin := TargetCellFiltering.LOSSourceOrigin.CENTER


## Gets the cells that can be targeted by [param source_actor].
func get_target_range(source_actor: Actor) -> TargetingData:
	var source_square := Square.new(
			source_actor.origin_cell, source_actor.cell_size)
	var full_range := _get_full_range(source_square)

	var visible_range := TargetCellFiltering.get_cells_in_line_of_sight(
			full_range, source_square, los_origin, source_actor.map)
	var targets := TargetCellFiltering.get_targets_in_range(
		visible_range, target_type, source_actor
	)

	return TargetingData.new(visible_range, targets)


## Get the set of cells representing the full unfiltered target range.[br]
## Can be overriden.
func _get_full_range(_source: Square) -> Array[Vector2i]:
	push_warning("TargetRange._get_full_range not implemented")
	return []
