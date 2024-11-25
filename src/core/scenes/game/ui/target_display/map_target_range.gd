class_name MapTargetRange
extends Node2D

@onready var _target_range_layer := $TargetRange as TileMapLayer
@onready var _valid_targets_layer := $ValidTargets as TileMapLayer
@onready var _aoe_layer := $AOE as TileMapLayer

const _TARGET_RANGE_TERRAIN_SET := 0
const _TARGET_RANGE_TERRAIN := 0

const _VALID_TARGETS_SOURCE_ID := 1
const _VALID_TARGETS_ALTAS_COORDS := Vector2i(0, 0)

const _AOE_TERRAIN_SET := 0
const _AOE_TERRAIN := 1


func set_target_range(target_range: Array[Vector2i],
		valid_targets: Array[Vector2i]) -> void:
	clear()
	_set_target_range(target_range)
	_set_valid_targets(valid_targets)


func set_aoe(aoe: Array[Vector2i]) -> void:
	_aoe_layer.clear()
	_aoe_layer.set_cells_terrain_connect(aoe, _AOE_TERRAIN_SET, _AOE_TERRAIN)


func clear() -> void:
	_target_range_layer.clear()
	_valid_targets_layer.clear()
	_aoe_layer.clear()


func _set_target_range(target_range: Array[Vector2i]) -> void:
	_target_range_layer.set_cells_terrain_connect(
			target_range, _TARGET_RANGE_TERRAIN_SET, _TARGET_RANGE_TERRAIN)


func _set_valid_targets(valid_targets: Array[Vector2i]) -> void:
	for cell in valid_targets:
		_valid_targets_layer.set_cell(
				cell, _VALID_TARGETS_SOURCE_ID, _VALID_TARGETS_ALTAS_COORDS)
