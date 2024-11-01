@icon("res://assets/editor/icons/ability_effect.png")
class_name AbilityEffect
extends Resource

## Class for applying an effect of an ability.


## Applies the effect at [param target] with a source at [param source].[br]
## [param source_actor] may be the source of the effect. [param source] may be
## different from the source actor's position and size.[br]
## Can be overriden.
func apply(_target: Vector2i, _source: Rect2i, _source_actor: Actor) -> void:
	pass
