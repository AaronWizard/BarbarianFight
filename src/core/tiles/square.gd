class_name Square

## A class for representing a square.
##
## A class for representing a square. Squares have a size and an origin position
## at its [b]top left[/b] corner.

## The square's position. Its position is at its [b]top left[/b] corner.
var position: Vector2i

## The square's size.
var size: int


## The [Rect2i] that matches the square.
var rect: Rect2i:
	get:
		return Rect2i(position, Vector2i(size, size))


func _init(new_position: Vector2i, new_size: int) -> void:
	position = new_position
	size = new_size
