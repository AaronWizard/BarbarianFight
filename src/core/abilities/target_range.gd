class_name TargetRange
extends Resource

## Class for getting the target range of an ability.


## The type of cells within the full range that are valid.
@export var target_type := TargetCellFiltering.TargetType.ANY

@export var los_origin := TargetCellFiltering.LOSSourceOrigin.CENTER

## Gets the cells that can be targeted by [param source_actor].[br]
## If [param source_size] is greater than 1, the ability source is treated as a
## square with [param source_cell] as the [b]top left[/b] corner (see
## [TileObject]). Assumed to be the cell size of [param source_actor].[br]
## [param source_cell] does not have to be the origin cell of
## [param source_actor].
func get_target_range(source_actor: Actor) -> TargetRangeData:
	var source_square := Square.new(
			source_actor.origin_cell, source_actor.cell_size)
	var full_range := _get_full_range(source_square)

	var visible_range := TargetCellFiltering.get_cells_in_line_of_sight(
		full_range, source_square, los_origin, source_actor)
	var valid_targets := TargetCellFiltering.get_valid_targets_from_range(
		visible_range, target_type, source_actor
	)

	return TargetRangeData.new(visible_range, valid_targets)


## Get the cells in the base full target range.[br]
## Can be overriden.
func _get_full_range(_source_square: Square) -> Array[Vector2i]:
	push_warning("TargetRange._get_full_range not implemented")
	return []
