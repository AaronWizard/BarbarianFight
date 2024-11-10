class_name PlayerMovementState
extends State

## Player control state where the player can move or wait.
##
## Player control state where the player can move or wait. Can enter targetting
## state from here.

@export var action_state: PlayerActionState
@export var target_state: PlayerTargetState

## Key is string, value is int
@export var action_combos: Dictionary

var _player: Actor
var _attack_targeting_data: TargetingData


func enter(data := {}) -> void:
	_player = data.player
	@warning_ignore("return_value_discarded")
	_player.map.mouse_clicked.connect(_map_clicked)

	if _player.attack_ability:
		_attack_targeting_data = _player.attack_ability.get_target_data(_player)


func exit() -> void:
	_player.map.mouse_clicked.disconnect(_map_clicked)
	_player = null
	_attack_targeting_data = null


func handle_input(_event: InputEvent) -> void:
	if Input.is_action_just_released("wait"):
		_end_turn(null)
	else:
		var ability_action_input: String = ""
		@warning_ignore("untyped_declaration")
		for a in action_combos.keys():
			@warning_ignore("unsafe_cast")
			var action := a as String
			if Input.is_action_just_released(action):
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


func _map_clicked(cell: Vector2i) -> void:
	if _player.rect.has_point(cell):
		_end_turn(null)
	elif cell in _attack_targeting_data.targets:
		assert(_player.attack_ability)
		var action := AbilityAction.new(_player, cell, _player.attack_ability)
		_end_turn(action)
	elif TileGeometry.cell_is_adjacent_to_rect(_player.rect, cell):
		var direction := TileGeometry.cardinal_dir_from_rect_to_cell(
				_player.rect, cell)
		var next_cell := _player.origin_cell + direction
		if _player.map.actor_can_enter_cell(_player, next_cell):
			var action := MoveAction.new(_player, next_cell)
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
	var targeting_data := ability.get_target_data(_player)

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
