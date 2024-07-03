class_name MapTargetRange
extends TileMap

const _LAYER_TARGET_RANGE := 0

const _TARGET_RANGE_TERRAIN_SET := 0
const _TARGET_RANGE_TERRAIN := 0


func set_target_range(target_range: Array[Vector2i]) -> void:
	clear()
	set_cells_terrain_connect(_LAYER_TARGET_RANGE, target_range,
			_TARGET_RANGE_TERRAIN_SET, _TARGET_RANGE_TERRAIN)
