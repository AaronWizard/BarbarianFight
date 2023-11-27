@tool
class_name ActorSprite
extends TileObject


@export var texture: Texture2D:
	get:
		var result: Texture2D = null
		if _sprite:
			result = _sprite.texture
		return result
	set(value):
		if _sprite:
			_sprite.texture = value


@onready var _sprite_origin: Node2D = $SpriteOrigin
@onready var _sprite: Sprite2D = $SpriteOrigin/Sprite


func _on_tile_size_changed(_old_size: Vector2i) -> void:
	_update_sprite_origin()


func _on_cell_size_changed(_old_size: Vector2i) -> void:
	_update_sprite_origin()


func _update_sprite_origin() -> void:
	if _sprite_origin:
		var center := Vector2(cell_size * tile_size) / 2.0
		center.y *= -1
		_sprite_origin.position = center
