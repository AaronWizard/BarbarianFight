class_name Square

## A class for representing a square.

var position: Vector2i
var size: int


var rect: Rect2i:
	get:
		return Rect2i(position, Vector2i(size, size))


func _init(new_position: Vector2i, new_size: int) -> void:
	position = new_position
	size = absi(new_size)
