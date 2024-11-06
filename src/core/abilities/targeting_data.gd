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
		return not _targets_by_selectable_cell.is_empty()


## The true target squares within the target/AOE range.
var targets: Array[Rect2i]:
	get:
		var result: Array[Rect2i] = []

		## I really wish Godot had typed dictionaries.
		var all_targets: Array[Rect2i] = []
		all_targets.assign(_targets_by_selectable_cell.values())
		for target in all_targets:
			if not target in result:
				result.append(target)

		return result


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


# The cells highlighted for the player representing the target/AOE range.
var _visible_range: Array[Vector2i]
# A dictionary of (Vector2i: Rect2i) pairs. The keys are cells the player may
# select, while the values are the corresponding target squares.
var _targets_by_selectable_cell: Dictionary


func _init(new_visible_range: Array[Vector2i], new_targets: Array[Rect2i]) \
		-> void:
	_visible_range = new_visible_range

	_targets_by_selectable_cell = {}

	for target in new_targets:
		if target.position in _visible_range:
			assert(not _targets_by_selectable_cell.has(target.position))
			_targets_by_selectable_cell[target.position] = target
	for target in new_targets:
		var target_cells := TileGeometry.cells_in_rect(target)
		for cell in target_cells:
			if (cell != target.position) and (cell in _visible_range) \
					and not _targets_by_selectable_cell.has(cell):
				_targets_by_selectable_cell[cell] = target


## Returns true if [param selected_cell] has a corresponding target.
func has_target_for_cell(selected_cell: Vector2i) -> bool:
	return _targets_by_selectable_cell.has(selected_cell)


## The target at the selected cell.
func target_at_selected_cell(selected_cell: Vector2i) -> Rect2i:
	@warning_ignore("unsafe_cast")
	return _targets_by_selectable_cell[selected_cell] as Rect2i
