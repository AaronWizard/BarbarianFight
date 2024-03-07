class_name RangeHighlights
extends Node2D

const _LAYER_TARGET_RANGE := 0

const _TILE_SOURCE_TARGET := 0
const _TILE_COORDS_TARGET := Vector2i(0, 0)

@onready var _range_map := $RangeMap as TileMap


func set_target_range(target_range: Array[Vector2i]) -> void:
	clear_range()
	for cell in target_range:
		_range_map.set_cell(
			_LAYER_TARGET_RANGE, cell,
			_TILE_SOURCE_TARGET, _TILE_COORDS_TARGET
		)


func clear_range() -> void:
	_range_map.clear()
