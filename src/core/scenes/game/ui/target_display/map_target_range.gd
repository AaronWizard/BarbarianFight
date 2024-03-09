class_name MapTargetRange
extends TileMap

const _LAYER_TARGET_RANGE := 0

const _TILE_SOURCE_TARGET := 0
const _TILE_COORDS_TARGET := Vector2i(0, 0)

func set_target_range(target_range: Array[Vector2i]) -> void:
	clear()
	for cell in target_range:
		set_cell(
			_LAYER_TARGET_RANGE, cell,
			_TILE_SOURCE_TARGET, _TILE_COORDS_TARGET
		)
