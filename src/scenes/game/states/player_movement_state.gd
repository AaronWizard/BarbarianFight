class_name PlayerMovementState
extends PlayerInputState

## Initial player control state where the player can wait, move, make standard
## attacks, or enter the states for ability selection and targeting.

## The state for selecting an action.
@export var select_ability_state: PlayerSelectAbilityState
## The state for targeting an action.
@export var target_state: PlayerTargetState

## The button to make the player actor wait a turn.
@export var wait_button: BaseButton

var _attack_targeting_data: TargetingData


func _ready() -> void:
	@warning_ignore("return_value_discarded")
	wait_button.pressed.connect(_wait)

	wait_button.disabled = true
	wait_button.visible = false


func enter() -> void:
	if player_actor.attack_ability:
		_attack_targeting_data = player_actor.attack_ability.get_target_data( \
				player_actor)

	wait_button.disabled = false
	wait_button.visible = true


func exit() -> void:
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
	var cell := player_actor.map.mouse_cell

	if cell in player_actor.covered_cells:
		request_state_change(select_ability_state)
	elif cell in _attack_targeting_data.selectable_cells:
		var target := _attack_targeting_data.target_at_selected_cell(cell)
		var action := AbilityAction.new(
			player_actor, target, player_actor.attack_ability
		)
		_end_turn(action)
	elif TileGeometry.cell_is_adjacent_to_rect(player_actor.rect, cell):
		var direction := TileGeometry.cardinal_dir_from_rect_to_cell(
				player_actor.rect, cell)
		var next_cell := player_actor.origin_cell + direction
		if player_actor.map.actor_can_enter_cell(player_actor, next_cell):
			var action := MoveAction.new(player_actor, next_cell)
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
	var target_cell := player_actor.origin_cell + direction
	if player_actor.map.actor_can_enter_cell(player_actor, target_cell):
		result = MoveAction.new(player_actor, target_cell)
	return result


func _try_keyboard_attack(direction: Vector2i) -> void:
	var edge_cells := TileGeometry.adjacent_edge_cells(
			player_actor.rect, direction)
	var targets: Array[Vector2i] = []
	for cell in edge_cells:
		if cell in _attack_targeting_data.targets:
			targets.append(cell)

	if targets.size() == 1:
		var action := AbilityAction.new(
				player_actor, targets[0], player_actor.attack_ability)
		_end_turn(action)
	elif targets.size() > 1:
		_start_ability_targeting(
				player_actor.attack_ability, targets[0])


func _get_direction_input() -> Vector2i:
	return Vector2i(Input.get_vector(
			"step_west", "step_east", "step_north", "step_south"))


func _start_ability_targeting(ability: Ability, initial_target: Vector2i) \
		-> void:
	game_control.set_ability_data(ability, initial_target)
	request_state_change(target_state)


func _wait() -> void:
	_end_turn(null)


func _end_turn_move(next_cell: Vector2i) -> void:
		var action := MoveAction.new(player_actor, next_cell)
		_end_turn(action)
