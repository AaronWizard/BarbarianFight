class_name MapTargetRange
extends Node2D

@onready var _target_range_layer := $TargetRange as TileMapLayer
@onready var _selectable_targets_layer := $SelectableTargets as TileMapLayer
@onready var _aoe_layer := $AOE as TileMapLayer

const _TARGET_RANGE_TERRAIN_SET := 0
const _TARGET_RANGE_TERRAIN := 0

const _SELECTABLE_TARGET_CELL_SOURCE_ID := 1
const _SELECTABLE_TARGET_CELL_ALTAS_COORDS := Vector2i(0, 0)


func set_target_range(target_range: Array[Vector2i],
		selectable_cells: Array[Vector2i]) -> void:
	clear()
	_set_target_range(target_range)
	_set_selectable_targets(selectable_cells)


func set_aoe(_aoe: Array[Vector2i]) -> void:
	_aoe_layer.clear()


func clear() -> void:
	_target_range_layer.clear()
	_selectable_targets_layer.clear()
	_aoe_layer.clear()


func _set_target_range(target_range: Array[Vector2i]) -> void:
	_target_range_layer.set_cells_terrain_connect(\
			target_range, _TARGET_RANGE_TERRAIN_SET, _TARGET_RANGE_TERRAIN)


func _set_selectable_targets(cells: Array[Vector2i]) -> void:
	for cell in cells:
		_selectable_targets_layer.set_cell(
			cell,
			_SELECTABLE_TARGET_CELL_SOURCE_ID,
			_SELECTABLE_TARGET_CELL_ALTAS_COORDS
		)
