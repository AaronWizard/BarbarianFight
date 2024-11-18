class_name PlayerMovementState
extends State

## Player control state where the player can move or wait.
##
## Player control state where the player can move or wait. Can enter targetting
## state from here.

## The state for doing the selected player action.
@export var action_state: PlayerActionState
## The state for targeting an action.
@export var target_state: PlayerTargetState

## The button to make the player actor wait a turn.
@export var wait_button: BaseButton

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

	wait_button.visible = true
	@warning_ignore("return_value_discarded")
	wait_button.pressed.connect(_wait)


func exit() -> void:
	_player.map.mouse_clicked.disconnect(_map_clicked)
	_player = null
	_attack_targeting_data = null

	wait_button.pressed.disconnect(_wait)


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
			@warning_ignore("unsafe_cast")
			var ability_index := action_combos[ability_action_input] as int
			var ability := _player.abilities[ability_index]
			var targeting_data := ability.get_target_data(_player)
			var initial_target := Vector2i.ZERO
			if targeting_data.has_targets:
				initial_target = targeting_data.targets[0]
			_start_ability_targeting(
				ability,
				targeting_data,
				initial_target,
				ability_action_input
			)
		else:
			_try_bump()


func _map_clicked(cell: Vector2i) -> void:
	if cell in _attack_targeting_data.targets:
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


func _try_bump() -> void:
	var direction := _get_direction_input()
	if direction.length_squared() == 1:
		var move_action := _try_keyboard_move(direction)
		if move_action:
			_end_turn(move_action)
		else:
			_try_keyboard_attack(direction)


func _try_keyboard_move(direction: Vector2i) -> TurnAction:
	var result: TurnAction = null
	var target_cell := _player.origin_cell + direction
	if _player.map.actor_can_enter_cell(_player, target_cell):
		result = MoveAction.new(_player, target_cell)
	return result


func _try_keyboard_attack(direction: Vector2i) -> void:
	var edge_cells := TileGeometry.adjacent_edge_cells(
			_player.rect, direction)
	var targets: Array[Vector2i] = []
	for cell in edge_cells:
		if cell in _attack_targeting_data.targets:
			targets.append(cell)

	if targets.size() == 1:
		var action := AbilityAction.new(
				_player, targets[0], _player.attack_ability)
		_end_turn(action)
	elif targets.size() > 1:
		_start_ability_targeting(
				_player.attack_ability, _attack_targeting_data, targets[0])


func _get_direction_input() -> Vector2i:
	return Vector2i(Input.get_vector(
			"step_west", "step_east", "step_north", "step_south"))


func _start_ability_targeting(ability: Ability, targeting_data: TargetingData,
		initial_target: Vector2i, input_code := "") -> void:
	var data := {
		player = _player,
		ability = ability,
		targeting_data = targeting_data,
		initial_target = initial_target
	}
	if not input_code.is_empty():
		data.input_code = input_code

	request_state_change(target_state, data)


func _wait() -> void:
	_end_turn(null)


func _end_turn_move(next_cell: Vector2i) -> void:
		var action := MoveAction.new(_player, next_cell)
		_end_turn(action)


func _end_turn(action: TurnAction) -> void:
	var data := { action = action }
	request_state_change(action_state, data)
