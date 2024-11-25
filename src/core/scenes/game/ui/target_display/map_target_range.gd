class_name MapTargetRange
extends Node2D

@onready var _target_range_layer := $TargetRange as TileMapLayer
@onready var _valid_targets_layer := $ValidTargets as TileMapLayer

const _TARGET_RANGE_TERRAIN_SET := 0
const _TARGET_RANGE_TERRAIN := 0

const _SELECTABLE_TARGET_CELL_SOURCE_ID := 1
const _SELECTABLE_TARGET_CELL_ALTAS_COORDS := Vector2i(0, 0)


func set_target_range(target_range: Array[Vector2i],
		selectable_cells: Array[Vector2i]) -> void:
	clear()
	_set_target_range(target_range)
	_set_valid_cells(selectable_cells)


func clear() -> void:
	_target_range_layer.clear()
	_valid_targets_layer.clear()


func _set_target_range(target_range: Array[Vector2i]) -> void:
	_target_range_layer.set_cells_terrain_connect(\
			target_range, _TARGET_RANGE_TERRAIN_SET, _TARGET_RANGE_TERRAIN)


func _set_valid_cells(cells: Array[Vector2i]) -> void:
	for cell in cells:
		_valid_targets_layer.set_cell(
			cell,
			_SELECTABLE_TARGET_CELL_SOURCE_ID,
			_SELECTABLE_TARGET_CELL_ALTAS_COORDS
		)
