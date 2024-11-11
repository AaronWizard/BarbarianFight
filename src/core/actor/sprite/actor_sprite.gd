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

## The sprite's attack animation has reached its hit frame.
signal attack_anim_hit

const _DEATH_DURATION := 0.2


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


## The animation for movement.
@export var anim_move: ActorSpriteAnimation

## The animation for attacks.
@export var anim_attack: ActorSpriteAnimation
## The name of the attack hit step in the attack animation.
@export var anim_attack_hit_step_name := ""

## The animation for getting hit from a direction.
@export var anim_hit: ActorSpriteAnimation

## The animation for getting hit without a source direction.[br]a
## Uses Vector2i.RIGHT for the target vector.
@export var anim_hit_no_direction: ActorSpriteAnimation

## The animation for dying.
@export var anim_death: ActorSpriteAnimation


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


## Animates an actor moving to an adjacent cell. [param target_vector] is
## relative to the actor's initial origin cell before moving to the new cell.
func move_step(target_vector: Vector2i) -> void:
	await anim_player.animate(anim_move, target_vector)


## Animates an actor attacking the given target_cell.[br]
## [param target_cell] is relative to the actor's cell.
func attack(target_cell: Vector2i) -> void:
	await anim_player.animate(anim_attack, target_cell)


## Animates an actor getting hit from [param direction].
func hit(direction := Vector2i.ZERO) -> void:
	if direction != Vector2i.ZERO:
		await anim_player.animate(anim_hit, direction)
	else:
		await anim_player.animate(anim_hit_no_direction, Vector2i.RIGHT)


## Animates the actor dying after being hit from the given direction.[br]
## [param direction] is normalized.
func die(direction := Vector2i.ZERO) -> void:
	var dissolve_tween := _start_dissolving()

	if direction != Vector2i.ZERO:
		await anim_player.animate(anim_death, direction)

	if dissolve_tween.is_running():
		await dissolve_tween.finished


func _tile_size_changed(_old_size: Vector2i) -> void:
	_update_sprite_origin()


func _cell_size_changed(_old_size: int) -> void:
	_update_sprite_origin()


func _update_sprite_origin() -> void:
	if _sprite_origin:
		var center := Vector2(cell_size * tile_size) / 2.0
		center.y *= -1
		_sprite_origin.position = center


func _start_dissolving() -> Tween:
	_start_animation()

	var result := create_tween()
	@warning_ignore("return_value_discarded")
	result.tween_property(
			_sprite.material, "shader_parameter/dissolve", 1, _DEATH_DURATION)
	@warning_ignore("return_value_discarded")
	result.tween_callback(_finish_animation).set_delay(_DEATH_DURATION)

	return result


func _on_actor_sprite_animation_player_started() -> void:
	_start_animation()


func _on_actor_sprite_animation_player_finished() -> void:
	_finish_animation()


func _on_actor_sprite_animation_player_named_step_finished(
		animation: ActorSpriteAnimation, step_name: String) -> void:
	if (animation == anim_attack) and (step_name == anim_attack_hit_step_name):
		attack_anim_hit.emit()


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
