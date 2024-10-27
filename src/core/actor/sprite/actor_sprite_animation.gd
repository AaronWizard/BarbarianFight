class_name ActorSpriteAnimation
extends Resource

## An animation for an actor sprite.
##
## An animation for an actor sprite. An actor sprite animation is composed from
## a list of steps describing where to move the sprite. A sprite's movement and
## positioning during its animation is relative to its origin cell and a target
## cell.

@export var steps: Array[ActorSpriteAnimationStep]


## Animates an actor's sprite. After the animation, the sprite's position is
## reset to zero.[br]
## [param target_vector] is relative to the actor's origin cell.
## [param tile_size] is in pixels.
func animate(sprite: Sprite2D, target_vector: Vector2, tile_size: Vector2i) \
		-> void:
	for step in steps:
		await step.animate(sprite, target_vector, tile_size)
	sprite.position = Vector2.ZERO
