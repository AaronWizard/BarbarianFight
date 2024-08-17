class_name PlayerTargetTracker

## Class for keeping track of player's target range and current target
## selection.
##
## When in targeting mode for a player's ability, keeps track of the targets
## within the ability's range and the currently selected target. The player can
## move this target using directional inputs.


var has_targets: bool:
	get:
		return not _targets.is_empty()


var target: Rect2i:
	get:
		return _targets[_current_target_index]


var _targets: Array[Rect2i] = []
var _current_target_index := -1


func set_targets(new_targets: Array[Rect2i]) -> void:
	clear()

	_targets.assign(new_targets)
	if not _targets.is_empty():
		_current_target_index = 0


func move_target(direction: Vector2i) -> void:
	var new_target_index := -1
	var min_dist_sqr := -1

	var moving_horizontal := direction.y == 0
	var moving_vertical := direction.x == 0

	for i in range(_targets.size()):
		var other_target := _targets[i]
		var diff := other_target.position - target.position
		if (moving_horizontal and (signi(diff.x) == signi(direction.x))) \
				or (moving_vertical and (signi(diff.y) == signi(direction.y))):
			if (min_dist_sqr < 0) \
					or (diff.length_squared() < min_dist_sqr):
				new_target_index = i
				min_dist_sqr = diff.length_squared()

	_current_target_index = new_target_index


func clear() -> void:
	_targets.clear()
	_current_target_index = -1
