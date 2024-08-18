class_name TargetDisplay
extends Node2D

@onready var _map_target_range := $MapTargetRange as MapTargetRange
@onready var _target := $TargetCell as TargetCell


func _ready() -> void:
	_target.visible = false


func show_range(targeting_data: TargetingData) -> void:
	_map_target_range.set_target_range(
			targeting_data.visible_range, targeting_data.selectable_cells)

	_target.visible = not targeting_data.targets.is_empty()
	if _target.visible:
		var start_target := targeting_data.targets[0]
		_target.set_cell(start_target.position)
		_target.cell_size = start_target.size


func set_target(target: Rect2i) -> void:
	_target.cell_size = target.size
	_target.move_to_cell(target.position)


func clear() -> void:
	_map_target_range.clear()
	_target.visible = false
