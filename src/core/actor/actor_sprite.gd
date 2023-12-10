@tool
class_name ActorSprite
extends TileObject

const _ANIM_MOVE_STEP := "move_step"


## The offset direction of the sprite from the center. Measured in tiles. Always
## normalized.
@export var sprite_offset_dir := Vector2.ZERO:
	set(value):
		sprite_offset_dir = value.normalized()
		if _sprite:
			_set_sprite_offset()


## The offset distance of the sprite from the center. Measured in tiles.
@export var sprite_offset_distance := 0.0:
	set(value):
		sprite_offset_distance = value
		if _sprite:
			_set_sprite_offset()


@onready var _sprite_origin := $SpriteOrigin as Node2D
@onready var _sprite := $SpriteOrigin/Sprite as Sprite2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func _tile_size_changed(_old_size: Vector2i) -> void:
	_update_sprite_origin()


func _cell_size_changed(_old_size: Vector2i) -> void:
	_update_sprite_origin()


func _update_sprite_origin() -> void:
	if _sprite_origin:
		var center := Vector2(cell_size * tile_size) / 2.0
		center.y *= -1
		_sprite_origin.position = center


func _set_sprite_offset() -> void:
	_sprite.position \
			= sprite_offset_dir * sprite_offset_distance * Vector2(tile_size)


func _animate_with_offset(anim_name: String, offset_dir: Vector2,
		offset_distance: float) -> void:
	sprite_offset_dir = offset_dir
	sprite_offset_distance = offset_distance

	_animation_player.play(anim_name)
	if _animation_player.is_playing():
		await _animation_player.animation_finished
