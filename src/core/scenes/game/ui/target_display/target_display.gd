class_name TargetDisplay
extends Node2D

@onready var _map_target_range := $MapTargetRange as MapTargetRange
@onready var _target_cell := $TargetCell as TargetCell


func _ready() -> void:
	_target_cell.visible = false


func show_range(range_cells: Array[Vector2i], start_cell: Vector2i) -> void:
	_map_target_range.set_target_range(range_cells)
	_target_cell.visible = true
	_target_cell.origin_cell = start_cell


func set_target_cell(cell: Vector2i) -> void:
	if _target_cell.origin_cell != cell:
		_target_cell.move_to_cell(cell)


func clear() -> void:
	_map_target_range.clear()
	_target_cell.visible = false
