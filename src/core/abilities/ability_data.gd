class_name AbilityData

## The parameters passed to [method AbilityEffect.apply].

## The ability's target.
var target: Vector2i

## The ability's source rectangle.
var source_rect: Rect2i

## The ability's source actor.
var source_actor: Actor


## The map the ability effect is being applied to.
var map: Map:
	get:
		return source_actor.map


func _init(new_target: Vector2i, new_source_rect: Rect2i, \
		new_source_actor: Actor) -> void:
	target = new_target
	source_rect = new_source_rect
	source_actor = new_source_actor
