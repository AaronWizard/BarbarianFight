class_name PlayerInput
extends Node

signal action_chosen(turn_action: TurnAction)

signal show_target_range(
		visible_range: Array[Vector2i], selectable_cells: Array[Vector2i],
		start_target: Square)
signal target_changed(new_target: Square)
signal hide_target_range


## Current state, determining what actions will be done in response to input.
enum State {
	## Player will move or attack.
	BUMP,
	## Player will dash.
	DASH,
	## Player will shove.
	SHOVE
}

@export var player_ability_index_dash := 0
@export var player_ability_index_shove := 1

var _player_actor: Actor
var _current_state := State.BUMP

var _current_ability: Ability = null
var _player_target_tracker := PlayerTargetTracker.new()


func _ready() -> void:
	set_process_unhandled_input(false)


func _unhandled_input(_event: InputEvent) -> void:
	_check_state()
	_update_current_ability()

	match _current_state:
		State.BUMP:
			_state_bump()
		State.DASH, State.SHOVE:
			_ability_input()


func set_player_actor(actor: Actor) -> void:
	_player_actor = actor


func start_turn() -> void:
	set_process_unhandled_input(true)
	_current_state = State.BUMP


func _end_turn(action: TurnAction) -> void:
	set_process_unhandled_input(false)
	_clear_ability()
	action_chosen.emit(action)


func _check_state() -> void:
	if Input.is_action_pressed("dash") and not Input.is_action_pressed("shove"):
		_current_state = State.DASH
	elif Input.is_action_pressed("shove") \
			and not Input.is_action_pressed("dash"):
		_current_state = State.SHOVE
	else:
		_current_state = State.BUMP


func _update_current_ability() -> void:
	var new_ability := _get_current_ability()
	if new_ability and (_current_ability != new_ability):
		_current_ability = new_ability
		_show_ability()
	elif not new_ability:
		_current_ability = null
		_clear_ability()


func _state_bump() -> void:
	if Input.is_action_just_released("wait"):
		_end_turn(null)
		action_chosen.emit(null)
	else:
		var action := _try_bump()
		if action:
			_end_turn(action)


func _ability_input() -> void:
	if _player_target_tracker.has_targets:
		if Input.is_action_just_released("wait"):
			var action := AbilityAction.new(
				_player_actor, _player_target_tracker.target.position,
				_current_ability
			)
			_end_turn(action)
		else:
			var direction := _get_direction_input()
			if direction.length_squared() == 1:
				_player_target_tracker.move_target(direction)
				target_changed.emit(_player_target_tracker.target)


func _show_ability() -> void:
	var targeting_data := _current_ability.get_target_range(_player_actor)

	_player_target_tracker.set_targets(targeting_data.targets)
	show_target_range.emit(
		targeting_data.visible_range, targeting_data.selectable_cells,
		_player_target_tracker.target
	)

	_current_state = State.DASH


func _clear_ability() -> void:
	_player_target_tracker.clear()
	hide_target_range.emit()

	_current_state = State.BUMP


func _get_current_ability() -> Ability:
	var result: Ability = null

	match _current_state:
		State.DASH:
			result = _player_actor.abilities[player_ability_index_dash]
		State.SHOVE:
			result = _player_actor.abilities[player_ability_index_shove]

	return result


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
