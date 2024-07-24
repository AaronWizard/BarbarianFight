class_name MapTargetRange
extends TileMap

const _LAYER_TARGET_RANGE := 0
const _LAYER_VALID_TARGETS := 1

const _TARGET_RANGE_TERRAIN_SET := 0
const _TARGET_RANGE_TERRAIN := 0

const _VALID_TARGET_SOURCE_ID := 1
const _VALID_TARGET_ALTAS_COORDS := Vector2i(0, 0)


func set_target_range(target_range: Array[Vector2i],
		valid_targets: Array[Square]) -> void:
	clear()
	set_cells_terrain_connect(_LAYER_TARGET_RANGE, target_range,
			_TARGET_RANGE_TERRAIN_SET, _TARGET_RANGE_TERRAIN)
	for square in valid_targets:
		set_cell(_LAYER_VALID_TARGETS, square.position, _VALID_TARGET_SOURCE_ID,
				_VALID_TARGET_ALTAS_COORDS)
