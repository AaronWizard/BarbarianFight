@tool
class_name Actor
extends TileObject

@export var definition: ActorDefinition

@onready var _sprite := $ActorSprite as ActorSprite


func _tile_size_changed(_old_size: Vector2i) -> void:
	_sprite.tile_size = tile_size


func _cell_size_changed(_old_size: Vector2i) -> void:
	_sprite.cell_size = cell_size
