class_name TargetDisplay
extends Node2D

## Displays the target range and currently selected target for a player ability.

@onready var _map_target_range := $MapTargetRange as MapTargetRange
@onready var _target := $TargetCell as TargetCell


func _ready() -> void:
	_target.visible = false


func show_range(targeting_data: TargetingData, initial_target: Vector2i) \
		-> void:
	_map_target_range.set_target_range(
			targeting_data.visible_range, targeting_data.selectable_cells)

	_target.visible = not targeting_data.targets.is_empty()
	if _target.visible:
		_target.set_cell(initial_target)
		_target.cell_size = targeting_data.get_target_size(initial_target)


func set_target(target_cell: Vector2i, target_size: Vector2i) -> void:
	_target.cell_size = target_size
	_target.move_to_cell(target_cell)


func clear() -> void:
	_map_target_range.clear()
	_target.visible = false
