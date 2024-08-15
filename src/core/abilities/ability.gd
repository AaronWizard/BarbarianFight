class_name Ability
extends Resource

## Class for an active ability an actor can perform.

@export var name := ""

## The ability's target range.
@export var target_range: TargetRange
## The ability's effect.
@export var effect: AbilityEffect


func get_target_range(source_actor: Actor) -> TargetingData:
	return target_range.get_target_range(source_actor)


## Performs the ability at [param target] for [param source_actor].[br]
## Assumes [param target] is a valid target.
func perform(target: Vector2i, source_actor: Actor) -> void:
	@warning_ignore("redundant_await")
	await effect.apply(target, source_actor.rect, source_actor)
