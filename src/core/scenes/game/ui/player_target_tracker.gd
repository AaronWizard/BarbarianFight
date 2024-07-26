class_name PlayerTargetTracker

## Class for keeping track of player's target range and current target
## selection.
##
## When in targeting mode for a player's action, keeps track of the tiles within
## the action's range and the currently selected target tile. The player can
## move this target using directional inputs.


var target_cell: Vector2i:
	get:
		return _target_cell


var _target_range: Array[Vector2i] = []
var _target_cell := Vector2i.ZERO


func set_target_range(new_target_range: Array[Vector2i]) -> void:
	_target_range.clear()
	_target_range.assign(new_target_range)

	var min_dist_sqr := -1
	for c in _target_range:
		var diff := c - _target_cell
		if (min_dist_sqr < 0) or (diff.length_squared() < min_dist_sqr):
			_target_cell = c
			min_dist_sqr = diff.length_squared()


func move_target(direction: Vector2i) -> void:
	var new_cell := _target_cell
	var min_dist_sqr := -1

	var moving_horizontal := direction.y == 0
	var moving_vertical := direction.x == 0

	for c in _target_range:
		var diff := c - _target_cell
		if (moving_horizontal and (signi(diff.x) == signi(direction.x))) \
				or (moving_vertical and (signi(diff.y) == signi(direction.y))):
			if (min_dist_sqr < 0) \
					or (diff.length_squared() < min_dist_sqr):
				new_cell = c
				min_dist_sqr = diff.length_squared()

	_target_cell = new_cell


func clear() -> void:
	_target_range.clear()
