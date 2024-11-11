class_name MoveSourceActorToTargetEffect
extends AbilityEffect

## Moves the source actor to the target cell.

## The animation the source actor's sprite plays for the dash.[br]
## The animation is run [i]after[/i] the actor's origin cell is updated.
@export var move_animation: ActorSpriteAnimation


func apply(target: Vector2i, _source: Rect2i, source_actor: Actor) -> void:
	if not source_actor.map.actor_can_enter_cell(source_actor, target):
		push_error("Actor '%s' could not enter cell at %v"
				% [source_actor, target])
		return

	var diff := target - source_actor.origin_cell

	source_actor.origin_cell = target
	if move_animation:
		await source_actor.sprite.anim_player.animate(move_animation, diff)
