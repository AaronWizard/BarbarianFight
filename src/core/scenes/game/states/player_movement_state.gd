class_name PlayerMovementState
extends State

@export var action_state: PlayerActionState
@export var target_state: PlayerTargetState

## Key is string, value is int
@export var action_combos: Dictionary

var _player: Actor


func enter(data := {}) -> void:
	_player = data.player


func handle_input(_event: InputEvent) -> void:
	if Input.is_action_just_released("wait"):
		_end_turn(null)
	else:
		var ability_action_input: String = ""
		@warning_ignore("untyped_declaration")
		for a in action_combos.keys():
			@warning_ignore("unsafe_cast")
			var action := a as String
			if Input.is_action_just_pressed(action):
				ability_action_input = action
				break
		if ability_action_input and not ability_action_input.is_empty():
			@warning_ignore("unsafe_call_argument")
			_start_ability_targeting(
					action_combos[ability_action_input], ability_action_input)
		else:
			var action := _try_bump()
			if action:
				_end_turn(action)


func _try_bump() -> TurnAction:
	var result: TurnAction = null

	var direction := _get_direction_input()
	if direction.length_squared() == 1:
		var target_cell := _player.origin_cell + direction
		if BumpAction.is_possible(_player, target_cell):
			result = BumpAction.new(_player, target_cell)

	return result


func _get_direction_input() -> Vector2i:
	return Vector2i(Input.get_vector(
			"step_west", "step_east", "step_north", "step_south"))


func _start_ability_targeting(ability_index: int, input_code: String) -> void:
	var ability := _player.abilities[ability_index]
	var targeting_data := ability.get_target_range(_player)

	var data := {
		player = _player,
		ability = ability,
		targeting_data = targeting_data,
		input_code = input_code
	}

	request_state_change(target_state, data)


func _end_turn(action: TurnAction) -> void:
	var data := { action = action }
	request_state_change(action_state, data)
