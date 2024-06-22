class_name TargetRange
extends Resource

## Class for getting the target range of an ability.


## The type of cells within the full range that are valid.
@export var target_type := TargetCellFiltering.TargetType.ANY

## What type of line of sight is needed between the source and a target cell.
@export var los_type := TargetCellFiltering.LineOfSightType.NONE


## Gets the cells that can be targeted from [param source_cell] by
## [param source_actor].[br]
## If [param source_size] is greater than 1, the ability source is treated as a
## square with [param source_cell] as the [b]top left[/b] corner (see
## [TileObject]). Assumed to be the cell size of [param source_actor].[br]
## [param source_cell] does not have to be the origin cell of
## [param source_actor].
func get_target_range(source_cell: Vector2i, source_size: int, \
		source_actor: Actor) -> TargetRangeData:
	var full_range := _get_full_range(source_cell, source_size)
	var valid_targets := TargetCellFiltering.get_valid_targets(
		full_range, source_cell, source_size,
		target_type, los_type, source_actor
	)
	return TargetRangeData.new(full_range, valid_targets, {}, {})


## Get the base full target range.[br]
## Can be overriden.
func _get_full_range(_source_cell: Vector2i, _source_size: int) \
		-> Array[Vector2i]:
	push_warning("TargetRange._get_full_range not implemented")
	return []
