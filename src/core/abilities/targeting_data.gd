class_name TargetingData

## A class representing the valid targets of an actor's ability.
##
## A class representing the valid targets of an actor's ability. Each target is
## associated with a size, for displaying a target rectangle to the player. e.g.
## If the ability targets actors, a target is an actor's origin cell while its
## size is the size of the actor. All cells covered by such a target rectangle
## are considered "selectable cells" that are mapped to the target cell.[br][br]
##
## TargetingData also has the cells representing the full visible target/AOE
## range shown to the player.


## True if valid targets exist.
var has_targets: bool:
	get:
		return not _targets.is_empty()


## The target cells within the target/AOE range.
var targets: Array[Vector2i]:
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
var _targets: Array[Vector2i]

# The cells highlighted for the player representing the target/AOE range.
var _visible_range: Array[Vector2i]

# A dictionary of (Vector2i: Vector2i) pairs. The keys are the target positions
# and the values are the target rectangle sizes.
var _target_sizes: Dictionary

# A dictionary of (Vector2i: int) pairs. The keys are cells the player may
# select, while the values are indices in _targets.
var _targets_by_selectable_cell: Dictionary


func _init(new_visible_range: Array[Vector2i],
		new_target_rects: Array[Rect2i]) -> void:
	_visible_range = new_visible_range

	_targets = []
	_target_sizes = {}
	_targets_by_selectable_cell = {}

	for i in range(0, new_target_rects.size()):
		var target_rect := new_target_rects[i]

		_targets.append(target_rect.position)
		_target_sizes[target_rect.position] = target_rect.size

		if target_rect.position in _visible_range:
			assert(not _targets_by_selectable_cell.has(target_rect.position))
			_targets_by_selectable_cell[target_rect.position] = i

	assert(_targets.size() == new_target_rects.size())
	for i in range(0, _targets.size()):
		var t_pos := _targets[i]
		@warning_ignore("unsafe_cast")
		var t_size := _target_sizes[t_pos] as Vector2i
		var t_rect := Rect2i(t_pos, t_size)

		var target_cells := TileGeometry.cells_in_rect(t_rect)
		for cell in target_cells:
			if (cell != t_pos) and (cell in _visible_range) \
					and not _targets_by_selectable_cell.has(cell):
				_targets_by_selectable_cell[cell] = i


## Returns true if [param selected_cell] has a corresponding target.
func has_target_for_cell(selected_cell: Vector2i) -> bool:
	return _targets_by_selectable_cell.has(selected_cell)


## The target at the selected cell.
func target_at_selected_cell(selected_cell: Vector2i) -> Vector2i:
	@warning_ignore("unsafe_cast")
	var target_index := _targets_by_selectable_cell[selected_cell] as int
	return _targets[target_index]


## The size of the target rectangle for the given target.
func get_target_size(target: Vector2i) -> Vector2i:
	@warning_ignore("unsafe_cast")
	var result := _target_sizes[target] as Vector2i
	return result
