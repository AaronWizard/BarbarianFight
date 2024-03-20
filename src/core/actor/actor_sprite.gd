@tool
class_name ActorSprite
extends TileObject

## An actor's sprite.
##
## An actor's sprite. Contains the actor's animations.

## The sprite has started animating.
signal animation_started

## The sprite has finished animating.
signal animation_finished

## The sprite's attack animation has reached its hit frame.
signal attack_anim_hit

const _ANIM_MOVE_STEP := "move_step"
const _ANIM_ATTACK := "attack"
const _ANIM_HIT_NO_DIRECTION := "hit_no_direction"
const _ANIM_HIT_DIRECTION := "hit_from_direction"
const _ANIM_DIE := "die"


## The offset direction of the sprite from the center. Measured in tiles. Always
## normalized.
@export var sprite_offset_dir := Vector2.ZERO:
	set(value):
		sprite_offset_dir = value.normalized()
		_set_sprite_offset()


## The offset distance of the sprite from the center. Measured in tiles.
@export var sprite_offset_distance := 0.0:
	set(value):
		sprite_offset_distance = value
		_set_sprite_offset()


## True if an animation is playing, false otherwise.
var animation_playing: bool:
	get:
		return _animation_playing


## A [RemoteTransform2D] attached to the sprite.
var remote_transform: RemoteTransform2D:
	get:
		return $SpriteOrigin/SpritePivot/Sprite/RemoteTransform2D \
				as RemoteTransform2D


var _animation_playing := false


@onready var _sprite_origin := $SpriteOrigin as Node2D
@onready var _sprite_pivot := $SpriteOrigin/SpritePivot as Node2D

@onready var _animation_player := $AnimationPlayer as AnimationPlayer


## Animates an actor moving to an adjacent cell.[br]
## [param direction] is normalized. Emits [signal ActorSprite.attack_anim_hit].
func move_step(direction: Vector2i) -> void:
	await _animate_with_start_offset(_ANIM_MOVE_STEP, direction)


## Animates an actor attacking in the given direction.[br]
## [param direction] is normalized.
func attack(direction: Vector2i) -> void:
	await _animate_with_start_offset(_ANIM_ATTACK, direction)


## Animates an actor getting hit from the given direction.[br]
## [param direction] is normalized.
func hit(direction := Vector2i.ZERO) -> void:
	if direction != Vector2i.ZERO:
		await _animate_with_start_offset(_ANIM_HIT_DIRECTION, direction)
	else:
		await _animate_with_start_offset(_ANIM_HIT_NO_DIRECTION, direction)


## Animates the actor dying after being hit from the given direction.[br]
## [param direction] is normalized.
func die(direction := Vector2i.ZERO) -> void:
	await _animate_with_start_offset(_ANIM_DIE, direction)


func _tile_size_changed(_old_size: Vector2i) -> void:
	_update_sprite_origin()


func _cell_size_changed(_old_size: int) -> void:
	_update_sprite_origin()


func _update_sprite_origin() -> void:
	if _sprite_origin:
		var center := Vector2(cell_size * tile_size) / 2.0
		center.y *= -1
		_sprite_origin.position = center


func _set_sprite_offset() -> void:
	if _sprite_pivot:
		_sprite_pivot.position = sprite_offset_dir * sprite_offset_distance \
				* Vector2(tile_size)


func _animate_with_start_offset(anim_name: String, offset_dir: Vector2) -> void:
	_animation_playing = true
	animation_started.emit()

	sprite_offset_dir = offset_dir
	sprite_offset_distance = 0

	_animation_player.play(anim_name)
	if _animation_player.is_playing():
		await _animation_player.animation_finished

	_animation_playing = false
	animation_finished.emit()


func _emit_attack_hit() -> void:
	if not Engine.is_editor_hint():
		attack_anim_hit.emit()
