class_name TargetingData

## A class representing the valid targets of an actor's ability.
##
## A class representing the valid targets of an actor's ability. These may be
## either the valid targets returned by a [TargetRange] where one may be
## selected for an ability, or they may be the targets returned by an
## [AreaOfEffect] where they will all be affected by the ability.[br][br]
##
## Each target is represented by a [Rect2i]. Only the position of a target
## rectangle is needed to use as an ability or AOE target. The size is meant for
## display to the player. For example, for an ability that targets actors a
## target rectangle's position would be an actor's origin cell while the size
## would be the actor's size. Here the target rectangle's position is used for
## the ability itself while its size is used for sizing the target graphic when
## an actor is selected as a target. All cells covered by a target rectangle
## map to the rectangle's position for the purposes of ability or AOE
## targetting.[br][br]
##
## TargetingData also has the cells representing the target/AOE range shown to
## the player. Within this range is a set of selectable cells, which each map to
## a target. These are based on the cells covered by the target rectangles.


## True if valid targets exist.
var has_targets: bool:
	get:
		return not _targets.is_empty()


## The true target squares within the target/AOE range.[br]
## Only the rectangle positions are necessary for running abilities.
## The rectangle sizes are for display to the player.
var targets: Array[Rect2i]:
	get:
		return _targets


## The cells highlighted for the player representing the target/AOE range.
var visible_range: Array[Vector2i]:
	get:
		return _visible_range


## The cells the player may select to choose a target.
var selectable_cells: Array[Vector2i]:
	get:
		var result: Array[Vector2i] = []
		result.assign(_targets_by_selectable_cell.keys())
		return result


# The targets.
var _targets: Array[Rect2i]

# The cells highlighted for the player representing the target/AOE range.
var _visible_range: Array[Vector2i]

# A dictionary of (Vector2i: int) pairs. The keys are cells the player may
# select, while the values are indices in _targets.
var _targets_by_selectable_cell: Dictionary


func _init(new_visible_range: Array[Vector2i], new_targets: Array[Rect2i]) \
		-> void:
	_targets = new_targets
	_visible_range = new_visible_range

	_targets_by_selectable_cell = {}

	for i in range(0, _targets.size()):
		var target := _targets[i]

		if target.position in _visible_range:
			assert(not _targets_by_selectable_cell.has(target.position))
			_targets_by_selectable_cell[target.position] = i

	for i in range(0, _targets.size()):
		var target := _targets[i]

		var target_cells := TileGeometry.cells_in_rect(target)
		for cell in target_cells:
			if (cell != target.position) and (cell in _visible_range) \
					and not _targets_by_selectable_cell.has(cell):
				_targets_by_selectable_cell[cell] = i


## Returns true if [param selected_cell] has a corresponding target.
func has_target_for_cell(selected_cell: Vector2i) -> bool:
	return _targets_by_selectable_cell.has(selected_cell)


## The target at the selected cell.
func target_at_selected_cell(selected_cell: Vector2i) -> Rect2i:
	@warning_ignore("unsafe_cast")
	var target_index := _targets_by_selectable_cell[selected_cell] as int
	return _targets[target_index]
