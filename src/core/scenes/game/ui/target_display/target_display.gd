class_name TargetDisplay
extends Node2D

@onready var _map_target_range := $MapTargetRange as MapTargetRange
@onready var _target_cell := $TargetCell as TargetCell


func _ready() -> void:
	_target_cell.visible = false


func show_range(visible_range: Array[Vector2i], valid_targets: Array[Square],
		start_target: Square) -> void:
	_map_target_range.set_target_range(visible_range, valid_targets)
	_target_cell.visible = true
	_target_cell.origin_cell = start_target.position
	_target_cell.cell_size = start_target.size


func set_target(target: Square) -> void:
	_target_cell.cell_size = target.size
	if _target_cell.origin_cell != target.position:
		_target_cell.move_to_cell(target.position)


func clear() -> void:
	_map_target_range.clear()
	_target_cell.visible = false
