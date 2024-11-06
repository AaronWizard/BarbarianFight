class_name PlayerTargetState
extends State

## Player control state where the player is selecting a target for an ability,

@export var action_state: PlayerActionState
@export var movement_state: PlayerMovementState

@export var target_display: TargetDisplay

var _player_target_tracker := PlayerTargetTracker.new()

var _player: Actor
var _ability: Ability
var _input_code: String


func enter(data := {}) -> void:
	_player = data.player
	_ability = data.ability
	_input_code = data.input_code

	@warning_ignore("unsafe_cast")
	var targeting_data := data.targeting_data as TargetingData
	_player_target_tracker.set_targets(targeting_data.targets)
	target_display.show_range(targeting_data)


func exit() -> void:
	target_display.clear()
	_player_target_tracker.clear()

	_player = null
	_ability = null
	_input_code = ""


func handle_input(_event: InputEvent) -> void:
	if Input.is_action_just_released(_input_code):
		request_state_change(movement_state, { player = _player })
	elif _player_target_tracker.has_targets:
		if Input.is_action_just_released("wait"):
			var action := AbilityAction.new(
				_player, _player_target_tracker.target.position, _ability
			)
			_end_turn(action)
		else:
			_try_move_target()


func _try_move_target() -> void:
	var direction := _get_direction_input()
	if direction.length_squared() == 1:
		_player_target_tracker.move_target(direction)
		target_display.set_target(_player_target_tracker.target)


func _get_direction_input() -> Vector2i:
	return Vector2i(Input.get_vector(
			"step_west", "step_east", "step_north", "step_south"))


func _end_turn(action: TurnAction) -> void:
	var data := { action = action }
	request_state_change(action_state, data)
