class_name MapTargetRange
extends TileMap

const _LAYER_VISIBLE_RANGE := 0
const _LAYER_SELECTABLE_CELLS := 1

const _VISIBLE_RANGE_TERRAIN_SET := 0
const _VISIBLE_RANGE_TERRAIN := 0

const _SELECTABLE_CELL_SOURCE_ID := 1
const _SELECTABLE_CELL_ALTAS_COORDS := Vector2i(0, 0)


func set_target_range(visible_range: Array[Vector2i],
		selectable_cells: Array[Vector2i]) -> void:
	clear()
	set_cells_terrain_connect(_LAYER_VISIBLE_RANGE, visible_range,
			_VISIBLE_RANGE_TERRAIN_SET, _VISIBLE_RANGE_TERRAIN)
	for cell in selectable_cells:
		set_cell(_LAYER_SELECTABLE_CELLS, cell, _SELECTABLE_CELL_SOURCE_ID,
				_SELECTABLE_CELL_ALTAS_COORDS)
