class_name ActorSpriteAnimationPlayer
extends Node

## Plays a [ActorSpriteAnimation] for an actor's sprite with a given target
## vector.
##
## Plays a [ActorSpriteAnimation] for an actor's sprite with a given target
## vector. Notifies when named animation steps have passed.

## The animation player has started playing an animation.
signal started
## The animation player has finished an animation.
signal finished

## Emmited when an animation step with a non-empty name has finished.
signal named_step_finished(animation: ActorSpriteAnimation, step_name: String)

## The sprite that gets animated.
@export var sprite: Sprite2D

## The size of the cells for the grid the sprite is animated on.
@export var tile_size := Vector2i(16, 16)

## The transform of the sprite. For controlling when the camera follows the
## sprite or the actor's base position.
@export var sprite_transform: RemoteTransform2D
## The transform of the camera following the sprite's actor. For controlling
## when the camera follows the sprite or the actor's base position.
@export var camera_transform: RemoteTransform2D


var playing: bool:
	get:
		return _playing


var _playing := false


## Animates an actor's sprite. After the animation, the sprite's position is
## reset to zero.[br]
## [param target_vector] is relative to the actor's origin cell.
## [param tile_size] is in pixels.
func animate(animation: ActorSpriteAnimation, target_vector: Vector2) -> void:
	_playing = true
	started.emit()

	if animation.camera_follow_sprite and sprite_transform and camera_transform:
		sprite_transform.remote_path = camera_transform.get_path()

	for step in animation.steps:
		await step.animate(sprite, target_vector, tile_size)
		if step.step_name and not step.step_name.is_empty():
			named_step_finished.emit(animation, step.step_name)
	sprite.position = Vector2.ZERO

	if sprite_transform:
		sprite_transform.remote_path = ""

	_playing = false
	finished.emit()
