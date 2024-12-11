class_name PlayerTargetKeyboardMover

## Class for moving the player's target with the keyboard when targetting an
## ability.


## The current target rectangle.
var target: Vector2i:
	get:
		return _targets[_current_target_index]
	set(value):
		var index := _targets.find(value)
		if index > -1:
			_current_target_index = index


var _targets: Array[Vector2i] = []
var _current_target_index := -1


## Set the target rectangles.
func set_targets(new_targets: Array[Vector2i], initial_target: Vector2i) \
		-> void:
	clear()

	_targets.assign(new_targets)
	if not _targets.is_empty():
		target = initial_target


## Moves the target in the given direction.
func move_target(direction: Vector2i) -> void:
	var new_target_index := -1
	var min_dist_sqr := -1

	var moving_horizontal := direction.y == 0
	var moving_vertical := direction.x == 0

	for i in range(_targets.size()):
		var other_target := _targets[i]
		var diff := other_target - target
		if (moving_horizontal and (signi(diff.x) == signi(direction.x))) \
				or (moving_vertical and (signi(diff.y) == signi(direction.y))):
			if (min_dist_sqr < 0) \
					or (diff.length_squared() < min_dist_sqr):
				new_target_index = i
				min_dist_sqr = diff.length_squared()

	_current_target_index = new_target_index


## Clears the targets.
func clear() -> void:
	_targets.clear()
	_current_target_index = -1
