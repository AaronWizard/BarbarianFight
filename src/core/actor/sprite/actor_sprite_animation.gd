@icon("res://assets/editor/icons/actor_sprite_animation.png")
class_name ActorSpriteAnimation
extends Resource

## An animation for an actor sprite.
##
## An animation for an actor sprite. An actor sprite animation is composed from
## a list of steps describing where to move the sprite. A sprite's movement and
## positioning during its animation is relative to its origin cell and a target
## cell.

## The steps of the animation
@export var steps: Array[ActorSpriteAnimationStep]

## If this is true and the camera is following the actor sprite, the camera
## follows the sprite itself instead of the actor sprite's cell.
@export var camera_follow_sprite := false

## The vector that will be used if the target vector is zero.
@export var fallback_for_zero_vector := Vector2.RIGHT
