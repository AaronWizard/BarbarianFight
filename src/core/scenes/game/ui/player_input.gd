class_name PlayerInput
extends Node

signal action_chosen(turn_action: TurnAction)

signal show_target_range(
		target_range: Array[Vector2i], start_target_cell: Vector2i)
signal target_cell_changed(new_target_cell: Vector2i)
signal hide_target_range


## Current state, determining what actions will be done in response to input.
enum State {
	## Player will move or attack.
	BUMP,
	## Player will dash.
	DASH
}

var _player_actor: Actor
var _current_state := State.BUMP

var _player_target_tracker := PlayerTargetTracker.new()


var enabled: bool:
	set(value):
		enabled = value
		set_process_unhandled_input(enabled)


func _ready() -> void:
	enabled = false
	_current_state = State.BUMP


func _unhandled_input(_event: InputEvent) -> void:
	_check_state()

	match _current_state:
		State.BUMP:
			_state_bump()
		State.DASH:
			_state_dash()


func set_player_actor(actor: Actor) -> void:
	_player_actor = actor


func _check_state() -> void:
	if Input.is_action_just_pressed("dash"):
		var target_range := TileGeometry.cells_in_range(
				_player_actor.rect, 2, 2)
		_player_target_tracker.set_target_range(target_range)
		show_target_range.emit(target_range, _player_target_tracker.target_cell)
		_current_state = State.DASH
	elif Input.is_action_just_released("dash"):
		_player_target_tracker.clear()
		hide_target_range.emit()
		_current_state = State.BUMP


func _state_bump() -> void:
	if Input.is_action_just_released("wait"):
		action_chosen.emit(null)
	else:
		var action := _try_bump()
		if action:
			action_chosen.emit(action)


func _state_dash() -> void:
	if Input.is_action_just_released("wait"):
		print("dashing to ", _player_target_tracker.target_cell)
	else:
		var direction := _get_direction_input()
		if direction.length_squared() == 1:
			_player_target_tracker.move_target(direction)
			target_cell_changed.emit(_player_target_tracker.target_cell)


func _try_bump() -> TurnAction:
	var result: TurnAction = null

	var direction := _get_direction_input()
	if direction.length_squared() == 1:
		var target_cell := _player_actor.origin_cell + direction
		if BumpAction.is_possible(_player_actor, target_cell):
			result = BumpAction.new(_player_actor, target_cell)

	return result


func _get_direction_input() -> Vector2i:
	return Vector2i(Input.get_vector(
			"step_west", "step_east", "step_north", "step_south"))
