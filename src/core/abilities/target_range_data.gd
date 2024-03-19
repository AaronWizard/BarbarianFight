class_name TargetRangeData

## The target tiles of an ability from [TargetRange].
##
## The target tiles of an ability from [TargetRange].
## [br][br]
## Includes the valid targets that may be used by the ability, as well as the
## visible cells to highlight for the player. e.g. For an ability that targets
## enemies within X cells, the valid targets are the origin cells of the enemies
## in range while the visible cells are all cells within X cells regardless of
## whether any enemies are on them.
## [br][br]
## Target cells may be mapped to a target rectangle shown to the player.
## e.g. If an ability targets actors, a target cell would be the origin cell of
## an actor while the corresponding target rectangle is the rectangle covering
## that actor.
## [br][br]
## A direction vector may be associated with a target cell. This is for
## abilities where the player chooses a direction instead of a specific cell.


## The valid targets.
var valid_targets: Array[Vector2i]:
	get:
		return _valid_targets


## The cells to highlight for the player.
var visible_range: Array[Vector2i]:
	get:
		return _visible_range


var _valid_targets: Array[Vector2i]
var _visible_range: Array[Vector2i]
var _targets_to_rects: Dictionary
var _directions_to_targets: Dictionary


func _init(
		new_valid_targets: Array[Vector2i],
		new_visible_range: Array[Vector2i],
		new_targets_to_rects: Dictionary,
		new_directions_to_targets: Dictionary) -> void:
	_valid_targets = new_valid_targets
	_visible_range = new_visible_range
	_targets_to_rects = new_targets_to_rects
	_directions_to_targets = new_directions_to_targets


## The rectangle associated with a target.
func target_rect(target: Vector2i) -> Rect2i:
	var result := Rect2i(target, Vector2i.ONE)
	if _targets_to_rects.has(target):
		result = _targets_to_rects[target]
	return result


## True if the given direction vector has an associated target.
func has_target_at_direction(direction: Vector2i) -> bool:
	return _directions_to_targets.has(direction)


## Gets the target cell associated with the given direction.[br]
## Raises an error if there isn't a valid target.
func target_from_direction(direction: Vector2i) -> Vector2i:
	return _directions_to_targets[direction]
