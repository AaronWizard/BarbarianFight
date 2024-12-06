class_name PlayerMovementState
extends State

## Initial player control state where the player can wait, move, make standard
## attacks, or enter the states for ability selection and targeting.

## The state for doing the selected player action.
@export var action_state: PlayerActionState
## The state for selecting an action.
@export var select_ability_state: PlayerSelectAbilityState
## The state for targeting an action.
@export var target_state: PlayerTargetState

## The button to make the player actor wait a turn.
@export var wait_button: BaseButton

var _player: Actor
var _attack_targeting_data: TargetingData


func _ready() -> void:
	@warning_ignore("return_value_discarded")
	wait_button.pressed.connect(_wait)

	wait_button.disabled = true
	wait_button.visible = false


func enter(data := {}) -> void:
	_player = data.player

	if _player.attack_ability:
		_attack_targeting_data = _player.attack_ability.get_target_data(_player)

	wait_button.disabled = false
	wait_button.visible = true


func exit() -> void:
	_player = null
	_attack_targeting_data = null

	wait_button.disabled = true


func handle_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("click"):
		_try_click()
	elif Input.is_action_just_released("wait"):
		_end_turn(null)
	else:
		_try_bump()


func _try_click() -> void:
	var cell := _player.map.mouse_cell

	if cell in _player.covered_cells:
		request_state_change(select_ability_state, {player = _player})
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
		initial_target: Vector2i) -> void:
	var data := {
		player = _player,
		ability = ability,
		targeting_data = targeting_data,
		initial_target = initial_target
	}

	request_state_change(target_state, data)


func _wait() -> void:
	_end_turn(null)


func _end_turn_move(next_cell: Vector2i) -> void:
		var action := MoveAction.new(_player, next_cell)
		_end_turn(action)


func _end_turn(action: TurnAction) -> void:
	var data := { action = action }
	request_state_change(action_state, data)
