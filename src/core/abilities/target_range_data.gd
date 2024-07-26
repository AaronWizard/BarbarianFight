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


## The valid targets.
var valid_targets: Array[Vector2i]:
	get:
		return _valid_targets


## The cells to highlight for the player.
var visible_range: Array[Vector2i]:
	get:
		return _visible_range


var _visible_range: Array[Vector2i]
var _valid_targets: Array[Vector2i]


func _init(
		new_visible_range: Array[Vector2i],
		new_valid_targets: Array[Vector2i]) -> void:
	_visible_range = new_visible_range
	_valid_targets = new_valid_targets
