@tool
class_name ActorSprite
extends TileObject


## The offset direction of the sprite. Measured in tiles.
@export var sprite_offset_vector := Vector2.ZERO:
	set(value):
		sprite_offset_vector = value
		if _sprite:
			_set_sprite_offset()


@export var sprite_offset_distance := 0.0:
	set(value):
		sprite_offset_distance = value
		if _sprite:
			_set_sprite_offset()


@onready var _sprite_origin := $SpriteOrigin as Node2D
@onready var _sprite := $SpriteOrigin/Sprite as Sprite2D


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
	_sprite.position = sprite_offset_vector * sprite_offset_distance * Vector2(tile_size)
