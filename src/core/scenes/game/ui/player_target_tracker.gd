class_name PlayerTargetTracker

## Class for keeping track of player's target range and current target
## selection.
##
## When in targeting mode for a player's action, keeps track of the tiles within
## the action's range and the currently selected target tile. The player can
## move this target using directional inputs.


var current_target: Square:
	get:
		return _current_target


var _target_range: Array[Square] = []
var _current_target: Square = null


func set_target_range(new_target_range: Array[Square]) -> void:
	_target_range.clear()
	_target_range.assign(new_target_range)

	if _current_target == null:
		_current_target = new_target_range[0]
	else:
		var min_dist_sqr := -1
		for sqr in _target_range:
			var diff := sqr.position - _current_target.position
			if (min_dist_sqr < 0) or (diff.length_squared() < min_dist_sqr):
				_current_target = sqr
				min_dist_sqr = diff.length_squared()


func move_target(direction: Vector2i) -> void:
	var new_square := _current_target
	var min_dist_sqr := -1

	var moving_horizontal := direction.y == 0
	var moving_vertical := direction.x == 0

	for sqr in _target_range:
		var diff := sqr.position - _current_target.position
		if (moving_horizontal and (signi(diff.x) == signi(direction.x))) \
				or (moving_vertical and (signi(diff.y) == signi(direction.y))):
			if (min_dist_sqr < 0) \
					or (diff.length_squared() < min_dist_sqr):
				new_square = sqr
				min_dist_sqr = diff.length_squared()

	_current_target = new_square


func clear() -> void:
	_target_range.clear()
