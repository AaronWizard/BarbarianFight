class_name PlayerInput
extends Node

signal action_chosen(turn_action: TurnAction)

signal show_target_range(
		target_range: Array[Vector2i], valid_targets: Array[Vector2i],
		start_target_cell: Vector2i)
signal target_cell_changed(new_target_cell: Vector2i)
signal hide_target_range


## Current state, determining what actions will be done in response to input.
enum State {
	## Player will move or attack.
	BUMP,
	## Player will dash.
	DASH
}

@export var player_dash_ability_index := 0

var _player_actor: Actor
var _current_state := State.BUMP

var _player_target_tracker := PlayerTargetTracker.new()


func _ready() -> void:
	set_process_unhandled_input(false)


func _unhandled_input(_event: InputEvent) -> void:
	_check_state()

	match _current_state:
		State.BUMP:
			_state_bump()
		State.DASH:
			_state_dash()


func set_player_actor(actor: Actor) -> void:
	_player_actor = actor


func start_turn() -> void:
	set_process_unhandled_input(true)
	_current_state = State.BUMP


func _end_turn(action: TurnAction) -> void:
	set_process_unhandled_input(false)
	_clear_dash()
	action_chosen.emit(action)


func _check_state() -> void:
	if Input.is_action_just_pressed("dash"):
		_show_dash()
	elif Input.is_action_just_released("dash"):
		_clear_dash()


func _state_bump() -> void:
	if Input.is_action_just_released("wait"):
		_end_turn(null)
		action_chosen.emit(null)
	else:
		var action := _try_bump()
		if action:
			_end_turn(action)


func _state_dash() -> void:
	if Input.is_action_just_released("wait"):
		var action := AbilityAction.new(
			_player_actor, _player_target_tracker.target_cell,
			_get_dash_ability()
		)
		_end_turn(action)
	else:
		var direction := _get_direction_input()
		if direction.length_squared() == 1:
			_player_target_tracker.move_target(direction)
			target_cell_changed.emit(_player_target_tracker.target_cell)


func _show_dash() -> void:
	var target_range_data := _get_dash_ability().get_target_range(_player_actor)

	_player_target_tracker.set_target_range(target_range_data.valid_targets)
	show_target_range.emit(
		target_range_data.visible_range, target_range_data.valid_targets,
		_player_target_tracker.target_cell
	)

	_current_state = State.DASH


func _clear_dash() -> void:
	_player_target_tracker.clear()
	hide_target_range.emit()

	_current_state = State.BUMP


func _get_dash_ability() -> Ability:
	return _player_actor.abilities[player_dash_ability_index]


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
