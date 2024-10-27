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

## The animation for getting hit.
@export var anim_hit: ActorSpriteAnimation

## The animation for dying.
@export var anim_death: ActorSpriteAnimation


## A [RemoteTransform2D] attached to the sprite.
var remote_transform: RemoteTransform2D:
	get:
		return $SpriteOrigin/SpritePivot/Sprite/RemoteTransform2D \
				as RemoteTransform2D


## True if an animation is playing, false otherwise.
var animation_playing: bool:
	get:
		return false


# Keep the sprite's origin at the center of the parent actor.
@onready var _sprite_origin := $SpriteOrigin as Node2D
# Position the sprite itself.
#@onready var _sprite_pivot := $SpriteOrigin/SpritePivot as Node2D


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
