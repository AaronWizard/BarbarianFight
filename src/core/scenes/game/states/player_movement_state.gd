class_name PlayerMovementState
extends State

@export var action_state: PlayerActionState
@export var target_state: PlayerTargetState

@export var ability_index_dash := 0
@export var ability_index_shove := 1

var _player: Actor


func enter(data := {}) -> void:
	_player = data.player


func handle_input(_event: InputEvent) -> void:
	if Input.is_action_just_released("wait"):
		_end_turn(null)
	elif Input.is_action_just_pressed("dash"):
		_start_ability_targeting(ability_index_dash, "dash")
	elif Input.is_action_just_pressed("shove"):
		_start_ability_targeting(ability_index_shove, "shove")
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
