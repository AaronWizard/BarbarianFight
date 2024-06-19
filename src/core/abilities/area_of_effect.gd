class_name AreaOfEffect
extends Resource

## Class for getting the area of effect around an ability target.


## The type of cells within the full range that are valid.
@export var cell_type := TargetCellFiltering.TargetType.ANY


## Get the area of effect at [param target_cell] for the ability targeted from
## [param source_cell].[br]
## If [param source_size] is greater than 1, the ability source is treated as a
## square with [param source_cell] as the [b]top left[/b] corner.[br]
## [param source_cell] does not have to be the origin cell of
## [param source_actor].
func get_aoe(target_cell: Vector2i, source_cell: Vector2i, source_size: int,
		source_actor: Actor) -> Array[Vector2i]:
	var full_range := _get_full_range(target_cell, source_cell, source_size)
	var valid_targets := TargetCellFiltering.get_valid_targets(
			full_range, cell_type, source_actor)
	return valid_targets


## Get the base full area of effect.[br]
## Can be overriden.
func _get_full_range(_target_cell: Vector2i,
		_source_cell: Vector2i, _source_size: int) -> Array[Vector2i]:
	push_warning("AreaOfEffect._get_full_range not implemented")
	return []
