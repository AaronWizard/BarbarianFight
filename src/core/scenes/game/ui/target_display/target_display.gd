class_name TargetDisplay
extends Node2D

@onready var _map_target_range := $MapTargetRange as MapTargetRange
@onready var _target := $TargetCell as TargetCell


func _ready() -> void:
	_target.visible = false


func show_range(visible_range: Array[Vector2i],
		selectable_cells: Array[Vector2i], start_target: Square) -> void:
	_map_target_range.set_target_range(visible_range, selectable_cells)

	_target.visible = start_target != null
	if _target.visible:
		_target.origin_cell = start_target.position
		_target.cell_size = start_target.size


func set_target(target: Square) -> void:
	_target.cell_size = target.size
	if _target.origin_cell != target.position:
		_target.move_to_cell(target.position)


func clear() -> void:
	_map_target_range.clear()
	_target.visible = false
