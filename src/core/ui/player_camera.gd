class_name PlayerCamera
extends Camera2D

## A camera for following the current player actor.
##
## A camera for following the current player actor. Can have a bounding
## rectangle set where the camera either won't go past the bounds if the bounds
## are bigger than the screen, or the will center the bounds if the bounds are
## smaller than the screen.

@onready var _bounds := get_viewport().get_visible_rect()


func _ready() -> void:
	_update_bounds()
	@warning_ignore("return_value_discarded")
	get_viewport().size_changed.connect(_update_bounds)


## Set the camera's bounds. Depending on the size of the screen, the camera will
## either avoid going past the bounds or will center over the bounds.
func set_bounds(rect: Rect2i) -> void:
	_bounds = rect
	_update_bounds()


func _update_bounds() -> void:
	limit_left = int(_bounds.position.x)
	limit_top = int(_bounds.position.y)

	limit_right = int(_bounds.end.x)
	limit_bottom = int(_bounds.end.y)

	var viewport := get_viewport()
	if viewport:
		var view_size := viewport.get_visible_rect().size

		if view_size.x > _bounds.size.x:
			var margin := int((view_size.x - _bounds.size.x) / 2)
			limit_left -= margin
			limit_right += margin

		if view_size.y > _bounds.size.y:
			var margin := int((view_size.y - _bounds.size.y) / 2)
			limit_top -= margin
			limit_bottom += margin
