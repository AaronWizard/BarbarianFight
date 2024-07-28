class_name TargetRangeData
extends Node

## A class representing the valid targets of an actor's ability.
##
## A class representing the valid targets of an actor's ability. These may be
## either the valid targets returned by a [TargetRange] where one may be
## selected for an ability, or they may be the targets returned by an
## [AreaOfEffect] where they will all be affected by the ability.[br][br]
##
## TargetRangeData has three components:[br]
## - A list of [Square] objects representing the actual targets.[br]
## - A list of [Vector2i] cells representing the target/AOE range shown to the
## player.[br]
## - A list of [Vector2i] cells representing the cells the player may select.
## These are mapped to a corresponding target.


## The true target squares within the target/AOE range.
var targets: Array[Square]:
	get:
		var result: Array[Square] = []

		## I really wish Godot had typed dictionaries.
		var all_targets: Array[Square] = []
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
# A dictionary of (Vector2i: Square) pairs. The keys are cells the player may
# select, while the values are the corresponding target squares.
var _targets_by_selectable_cell: Dictionary


func _init(new_visible_range: Array[Vector2i], new_targets: Array[Square]) \
		-> void:
	_visible_range = new_visible_range

	_targets_by_selectable_cell = {}
	for target in new_targets:
		var target_cells := TileGeometry.cells_in_rect(target.rect)
		for cell in target_cells:
			if cell in _visible_range:
				_targets_by_selectable_cell[cell] = target
		# Prioritize target origin cells
		if target.position in _visible_range:
			_targets_by_selectable_cell[target.position] = target


## The target at the selected cell.
func target_at_selected_cell(selected_cell: Vector2i) -> Square:
	@warning_ignore("unsafe_cast")
	return _targets_by_selectable_cell[selected_cell] as Square
