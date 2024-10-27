class_name ActorSpriteAnimationPlayer
extends Node

## Plays a [ActorSpriteAnimation] for an actor's sprite with a given target
## vector.
##
## Plays a [ActorSpriteAnimation] for an actor's sprite with a given target
## vector. Notifies when named animation steps have passed.

## Emmited when an animation step with a non-empty name has finished.
signal named_step_finished(animation: ActorSpriteAnimation, step_name: String)


## Animates an actor's sprite. After the animation, the sprite's position is
## reset to zero.[br]
## [param target_vector] is relative to the actor's origin cell.
## [param tile_size] is in pixels.
func animate(animation: ActorSpriteAnimation, sprite: Sprite2D,
		target_vector: Vector2, tile_size: Vector2i) -> void:
	for step in animation.steps:
		await step.animate(sprite, target_vector, tile_size)
		if step.step_name and not step.step_name.is_empty():
			named_step_finished.emit(animation, step.step_name)
	sprite.position = Vector2.ZERO
