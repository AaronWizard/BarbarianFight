class_name PlayerTargetTracker

## Class for keeping track of player's target range and current target
## selection.
##
## When in targeting mode for a player's ability, keeps track of the targets
## within the ability's range and the currently selected target. The player can
## move this target using directional inputs.


var target: Square:
	get:
		return _current_target


var _targets: Array[Square] = []
var _current_target: Square


func set_targets(new_targets: Array[Square]) -> void:
	_targets.clear()
	_targets.assign(new_targets)

	_current_target = _targets[0]


func move_target(direction: Vector2i) -> void:
	var new_target := _current_target
	var min_dist_sqr := -1

	var moving_horizontal := direction.y == 0
	var moving_vertical := direction.x == 0

	for t in _targets:
		var diff := t.position - _current_target.position
		if (moving_horizontal and (signi(diff.x) == signi(direction.x))) \
				or (moving_vertical and (signi(diff.y) == signi(direction.y))):
			if (min_dist_sqr < 0) \
					or (diff.length_squared() < min_dist_sqr):
				new_target = t
				min_dist_sqr = diff.length_squared()

	_current_target = new_target


func clear() -> void:
	_targets.clear()
	_current_target = null
