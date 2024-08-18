class_name MapTargetRange
extends Node2D

@onready var target_range := $TargetRange as TileMapLayer
@onready var valid_targets := $ValidTargets as TileMapLayer

const _VISIBLE_RANGE_TERRAIN_SET := 0
const _VISIBLE_RANGE_TERRAIN := 0

const _SELECTABLE_CELL_SOURCE_ID := 1
const _SELECTABLE_CELL_ALTAS_COORDS := Vector2i(0, 0)


func set_target_range(visible_range: Array[Vector2i],
		selectable_cells: Array[Vector2i]) -> void:
	clear()

	target_range.set_cells_terrain_connect(\
			visible_range, _VISIBLE_RANGE_TERRAIN_SET, _VISIBLE_RANGE_TERRAIN)
	for cell in selectable_cells:
		valid_targets.set_cell(
				cell, _SELECTABLE_CELL_SOURCE_ID, _SELECTABLE_CELL_ALTAS_COORDS)


func clear() -> void:
	target_range.clear()
	valid_targets.clear()
