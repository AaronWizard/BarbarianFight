@tool
class_name TargetCell
extends Node2D

## The marker for the player's current target.

const _MOVE_TIME := 0.2

@export var tile_size := Vector2i(16, 16):
	set(value):
		tile_size = value
		_position_corners()


@export var cell_size := Vector2i.ONE:
	set(value):
		cell_size = value
		_position_corners()


# $NW always at top-left
@onready var _ne := $NE as Node2D
@onready var _se := $SE as Node2D
@onready var _sw := $SW as Node2D
#@onready var _nw := $NW as Node2D


func _ready() -> void:
	_position_corners()


func set_cell(new_cell: Vector2i) -> void:
	position = new_cell * tile_size


## Move target to [param new_cell] with animation
func move_to_cell(new_cell: Vector2i) -> void:
	var next_position := Vector2(new_cell * tile_size)
	if Vector2i(next_position - position) != Vector2i.ZERO:
		var tween := get_tree().create_tween()
		@warning_ignore("return_value_discarded")
		tween.tween_property(self, "position", next_position, _MOVE_TIME) \
				.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)


func _tile_size_changed(_old_size: Vector2i) -> void:
	_position_corners()


func _cell_size_changed(_old_size: int) -> void:
	_position_corners()


func _position_corners() -> void:
	_ne.position.x = cell_size.x * tile_size.x
	_se.position.x = cell_size.x * tile_size.x

	_se.position.y = cell_size.y * tile_size.y
	_sw.position.y = cell_size.y * tile_size.y
