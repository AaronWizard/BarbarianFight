class_name Ability
extends Resource

## Class for an active ability an actor can perform.

@export var name := ""

## The ability's target range.
@export var target_range: TargetRange
## The ability's effect.
@export var effect: AbilityEffect


func get_target_range(source_actor: Actor) -> TargetRangeData:
	return target_range.get_target_range(source_actor)


## Performs the ability at [param target] for [param source_actor].[br]
## Assumes [param target] is a valid target.
func perform(target: Square, source_actor: Actor) -> void:
	@warning_ignore("redundant_await")
	await effect.apply(
		target, Square.new(source_actor.origin_cell, source_actor.cell_size),
		source_actor
	)
