@tool
@icon("res://assets/editor/icons/actor_sprite.png")
class_name ActorSprite
extends Node2D

## An actor's sprite.
##
## An actor's sprite. Can be animated.


## The sprite has started animating.
signal animation_started

## The sprite has finished animating.
signal animation_finished

const _DISSOLVE_DURATION := 0.2


## The size in pixels of the grid cells the tile object aligns itself with.
@export var tile_size := Vector2i(16, 16):
	set(value):
		tile_size = value
		anim_player.tile_size = value
		_update_sprite_origin()


## The width and height in cells of the tile object.
@export_range(1, 1, 1, "or_greater") var cell_size := 1:
	set(value):
		cell_size = value
		_update_sprite_origin()


## The sprite's animation player.
var anim_player: ActorSpriteAnimationPlayer:
	get:
		return $ActorSpriteAnimationPlayer


## True if an animation is playing, false otherwise.
var animation_playing: bool:
	get:
		return _animations_remaining > 0


var _camera_transform: RemoteTransform2D:
	get:
		return $SpriteOrigin/CameraTransform as RemoteTransform2D


# Either anim_player animation or dissolve animation.
var _animations_remaining := 0


# Keep the sprite's origin at the center of the parent actor.
@onready var _sprite_origin := $SpriteOrigin as Node2D

@onready var _sprite := $SpriteOrigin/Sprite as Sprite2D


func _ready() -> void:
	tile_size = tile_size


## Make [param camera] follow this sprite.
func follow_with_camera(camera: Camera2D) -> void:
	_camera_transform.remote_path = camera.get_path()


## If the actor is playing an animation, waits for the animation to finish.
func wait_for_animation() -> void:
	if animation_playing:
		await animation_finished


func _tile_size_changed(_old_size: Vector2i) -> void:
	_update_sprite_origin()


func _cell_size_changed(_old_size: int) -> void:
	_update_sprite_origin()


func _update_sprite_origin() -> void:
	if _sprite_origin:
		var center := Vector2(cell_size * tile_size) / 2.0
		center.y *= -1
		_sprite_origin.position = center


func dissolve() -> void:
	_start_animation()

	var tween := create_tween()
	@warning_ignore("return_value_discarded")
	tween.tween_property(_sprite.material, "shader_parameter/dissolve", 1,
			_DISSOLVE_DURATION)
	@warning_ignore("return_value_discarded")
	tween.tween_callback(_finish_animation).set_delay(_DISSOLVE_DURATION)

	await tween.finished


func _on_actor_sprite_animation_player_started() -> void:
	_start_animation()


func _on_actor_sprite_animation_player_finished() -> void:
	_finish_animation()


func _start_animation() -> void:
	var starting := _animations_remaining == 0
	_animations_remaining += 1
	if starting:
		animation_started.emit()


func _finish_animation() -> void:
	_animations_remaining -= 1
	assert(_animations_remaining >= 0)
	if _animations_remaining == 0:
		animation_finished.emit()
