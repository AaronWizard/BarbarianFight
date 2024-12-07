class_name MoveSourceActorToTargetEffect
extends AbilityEffect

## Moves the source actor to the target cell.

## The animation the source actor's sprite plays for the dash.[br]
## The animation is run [i]after[/i] the actor's origin cell is updated.
@export var move_animation: ActorSpriteAnimation


func apply(data: AbilityData) -> void:
	if not data.map.actor_can_enter_cell(data.source_actor, data.target):
		push_error("Actor '%s' could not enter cell at %v"
				% [data.source_actor, data.target])
		return

	var diff := data.target - data.source_actor.origin_cell

	data.source_actor.origin_cell = data.target
	if move_animation:
		await data.source_actor.sprite.anim_player.animate(move_animation, diff)
