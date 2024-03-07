@tool
class_name TargetCell
extends TileObject

## The marker for the player's target cell.

const _MOVE_TIME := 0.2

@onready var _corner_origin := $CornerOrigin as Node2D

@onready var _nw := $CornerOrigin/NW as Node2D
@onready var _ne := $CornerOrigin/NE as Node2D
@onready var _se := $CornerOrigin/SE as Node2D


func _ready() -> void:
	_position_corners()


## Move target to [param new_cell] with animation
func move_to_cell(new_cell: Vector2i) -> void:
	var diff := (new_cell - origin_cell) * tile_size

	origin_cell = new_cell

	_corner_origin.position = -diff
	var tween := get_tree().create_tween()
	@warning_ignore("return_value_discarded")
	tween.tween_property(_corner_origin, "position", Vector2.ZERO, _MOVE_TIME) \
			.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	if tween.is_running():
		await tween.finished


func _tile_size_changed(_old_size: Vector2i) -> void:
	_position_corners()


func _cell_size_changed(_old_size: Vector2i) -> void:
	_position_corners()


func _position_corners() -> void:
	_ne.position.x = cell_size.x * tile_size.x
	_se.position.x = cell_size.x * tile_size.x

	_nw.position.y = -cell_size.y * tile_size.y
	_ne.position.y = -cell_size.y * tile_size.y
