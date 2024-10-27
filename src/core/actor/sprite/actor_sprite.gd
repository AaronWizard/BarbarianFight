@tool
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


## The size in pixels of the grid cells the tile object aligns itself with.
@export var tile_size := Vector2i(16, 16):
	set(value):
		tile_size = value
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

## The animation for getting hit.
@export var anim_hit: ActorSpriteAnimation

## The animation for dying.
@export var anim_death: ActorSpriteAnimation


## A [RemoteTransform2D] attached to the sprite.
var remote_transform: RemoteTransform2D:
	get:
		return $SpriteOrigin/Sprite/RemoteTransform2D as RemoteTransform2D


## True if an animation is playing, false otherwise.
var animation_playing: bool:
	get:
		return _animation_playing


var _animation_playing := false


# Keep the sprite's origin at the center of the parent actor.
@onready var _sprite_origin := $SpriteOrigin as Node2D

@onready var _sprite := $SpriteOrigin/Sprite as Sprite2D
@onready var _sprite_anim_player \
		:= $ActorSpriteAnimationPlayer as ActorSpriteAnimationPlayer


## Animate the sprite. [param target_vector] is relative to the actor's origin
## cell.
func play_animation(target_vector: Vector2i, anim: ActorSpriteAnimation) \
		-> void:
	_animation_playing = true
	animation_started.emit()

	await _sprite_anim_player.animate(anim, _sprite, target_vector, tile_size)

	_animation_playing = false
	animation_finished.emit()


## Animates an actor moving to an adjacent cell. [param target_vector] is
## relative to the actor's initial origin cell before moving to the new cell.
func move_step(target_vector: Vector2i) -> void:
	await play_animation(target_vector, anim_move)


## Animates an actor attacking in the given target.[br]
## [param target] is in tiles and is relative to the actor's cell.
func attack(target: Vector2i) -> void:
	await play_animation(target, anim_attack)


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


func _on_actor_sprite_animation_player_named_step_finished(
		animation: ActorSpriteAnimation, step_name: String) -> void:
	if (animation == anim_attack) and (step_name == anim_attack_hit_step_name):
		attack_anim_hit.emit()
