class_name MoveSourceActorToTargetEffect
extends AbilityEffect

## Moves the source actor to the target cell.

## The animation the source actor's sprite plays for the dash.
@export var move_animation: ActorSpriteAnimation


func apply(target: Vector2i, _source: Rect2i, source_actor: Actor) -> void:
	if not source_actor.map.actor_can_enter_cell(source_actor, target):
		push_error("Actor '%s' could not enter cell at %v"
				% [source_actor, target])
		return

	var diff := target - source_actor.origin_cell

	source_actor.origin_cell = target
	await source_actor.sprite.play_animation(diff, move_animation)
