@icon("res://assets/editor/icons/target_range.png")
class_name TargetRange
extends Resource

## Class for getting the target range of an actor's ability.

## Class for getting the target range of an actor's ability. Returns a
## [TargetingData] object containing the set of possible targets.


## Gets the targets for an abilith whose source is [param source_actor].
func get_target_range(source_actor: Actor) -> TargetingData:
	var target_range := _get_target_range(source_actor)
	var targets := _get_targets(target_range, source_actor)
	_range_post_processing(target_range, source_actor)

	return TargetingData.new(target_range, targets)


## Get the set of cells representing the full unfiltered target range.[br]
## Can be overriden.
func _get_target_range(_source_actor: Actor) -> Array[Vector2i]:
	push_warning("TargetRange._get_target_range not implemented")
	return []


## Get the set of targets within [param target_range].[br]
## Can be overriden.
func _get_targets(_target_range: Array[Vector2i], _source_actor: Actor) \
		-> Array[Rect2i]:
	push_warning("TargetRange._get_targets not implemented")
	return []


## Post-processing of the target range.[br]
## Can be overriden.
func _range_post_processing(_target_range: Array[Vector2i],
		_source_actor: Actor) -> void:
	pass
