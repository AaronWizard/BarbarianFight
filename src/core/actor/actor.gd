@tool
class_name Actor
extends TileObject

@export var sprite: Texture2D:
	get:
		var result: Texture2D = null
		if _sprite:
			result = _sprite.texture
		return result
	set(value):
		if _sprite:
			_sprite.texture = value


@export var definition: ActorDefinition

@onready var _sprite: ActorSprite = $ActorSprite


func _on_tile_size_changed(_old_size: Vector2i) -> void:
	_sprite.tile_size = tile_size


func _on_origin_cell_changed(_old_cell: Vector2i) -> void:
	pass # Replace with function body.


func _on_cell_size_changed(_old_size: Vector2i) -> void:
	_sprite.cell_size = cell_size
