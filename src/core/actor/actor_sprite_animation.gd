class_name ActorSpriteAnimation
extends Resource

## An animation for an actor sprite.
##
## An animation for an actor sprite. An actor sprite animation is composed from
## a list of steps describing where to move the sprite. A sprite's movement and
## positioning during its animation is relative to its origin cell and a target
## cell.

@export var steps: Array[ActorSpriteAnimationStep]
