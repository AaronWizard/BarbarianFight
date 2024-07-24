class_name AbilityEffect
extends Resource

## Class for applying an effect of an ability.


## Applies the effect at [param target]. The effect may have a source located at
## [param source].[br]
## [param source_actor] may be the source of the effect. The source square may
## be different from the source actor.[br]
## Can be overriden.
func apply(_target: Square, _source: Square, _source_actor: Actor) -> void:
	pass
