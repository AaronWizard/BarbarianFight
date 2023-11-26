@tool
class_name ActorSprite
extends TileObject

@onready var _sprite_origin: Node2D = $SpriteOrigin
@onready var _sprite: Sprite2D = $SpriteOrigin/Sprite


func _on_tile_size_changed(old_size: Vector2i) -> void:
	_update_sprite_origin()


func _on_cell_size_changed(old_size: Vector2i) -> void:
	_update_sprite_origin()


func _update_sprite_origin() -> void:
	if _sprite_origin:
		var center := Vector2(cell_size * tile_size) / 2.0
		center.y *= -1
		_sprite_origin.position = center
