class_name AbilityEffect
extends Resource

## Class for applying an effect of an ability.


## Applies the effect at [param target_cell].[br]
## The effect may have a source located at [param source_cell]. This source may
## be a square with [param source_size] as the dimensions. If
## [param source_size] is greater than 1, [param source_cell] is the [b]top
## left[/b] corner.[br]
## [param source_actor] may be the source of the effect. The source cell may be
## different from the source actor.[br]
## Can be overriden.
func apply(_target_cell: Vector2i, _source_cell: Vector2i,
		_source_size: int, _source_actor: Actor) -> void:
	pass
