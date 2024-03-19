class_name TargetRangeData

## Object containing the target tiles of an ability.


## The valid targets.
var valid_targets: Array[Vector2i]:
	get:
		return []


## The cells to highlight for the player. The valid targets are a subset of the
## visible range.
var visible_range: Array[Vector2i]:
	get:
		return []


## The rectangle associated with a target.
func target_rect(target: Vector2i) -> Rect2i:
	return Rect2i(target, Vector2i.ONE)


## True if the given direction vector has an associated target.
func has_target_at_direction(direction: Vector2i) -> bool:
	return false


## Gets the target cell associated with the given direction.[br]
## Raises an error if there isn't a valid target.
func target_from_direction(direction: Vector2i) -> Vector2i:
	return Vector2i()
