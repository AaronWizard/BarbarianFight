class_name PlayerTargetState
extends State

## Player control state where the player is selecting a target for an ability.

## The state for doing the selected player action.
@export var action_state: PlayerActionState
## The state for standard player movement and attacks.
@export var movement_state: PlayerMovementState

## Displays the target range and current target.
@export var target_display: TargetDisplay

## The button to make the player actor wait a turn. Will hide this button when
## targeting.
@export var wait_button: CanvasItem

# Also used to keep track of the currently selected target.
var _target_keyboard_mover := PlayerTargetKeyboardMover.new()

var _player: Actor
var _ability: Ability
var _targetting_data: TargetingData

var _input_code: String

@onready var _ability_display := $CanvasLayer/AbilityDisplay as AbilityDisplay


func _ready() -> void:
	@warning_ignore("return_value_discarded")
	_ability_display.cancelled.connect(_on_ability_cancelled)
	_ability_display.visible = false


func enter(data := {}) -> void:
	_player = data.player
	_ability = data.ability
	_targetting_data = data.targeting_data

	if data.has("input_code"):
		_input_code = data.input_code
	else:
		_input_code = ""

	@warning_ignore("unsafe_cast")
	var initial_target := data.initial_target as Vector2i

	_target_keyboard_mover.set_targets(_targetting_data.targets, initial_target)
	target_display.show_range(_targetting_data, initial_target)

	@warning_ignore("return_value_discarded")
	_player.map.mouse_clicked.connect(_map_clicked)

	_ability_display.set_ability_name(_ability.name)

	_ability_display.visible = true
	wait_button.visible = false


func exit() -> void:
	target_display.clear()
	_target_keyboard_mover.clear()

	_player.map.mouse_clicked.disconnect(_map_clicked)

	_player = null
	_ability = null
	_targetting_data = null
	_input_code = ""

	_ability_display.visible = false


func handle_input(_event: InputEvent) -> void:
	if Input.is_action_just_released("targeting_cancel") or (
		not _input_code.is_empty()
		and Input.is_action_just_released(_input_code)
	):
		_cancel_targeting()
	elif _targetting_data.has_targets:
		if Input.is_action_just_released("wait"):
			_end_turn(_target_keyboard_mover.target)
		else:
			_try_move_target()


func _on_ability_cancelled() -> void:
	_cancel_targeting()


func _map_clicked(cell: Vector2i) -> void:
	if _targetting_data.has_target_for_cell(cell):
		var target := _targetting_data.target_at_selected_cell(cell)
		if target == _target_keyboard_mover.target:
			_end_turn(target)
		else:
			_target_keyboard_mover.target = target
			assert(_target_keyboard_mover.target == target)
			target_display.set_target(
					target, _targetting_data.get_target_size(target))


func _try_move_target() -> void:
	var direction := _get_direction_input()
	if direction.length_squared() == 1:
		_target_keyboard_mover.move_target(direction)
		target_display.set_target(
			_target_keyboard_mover.target,
			_targetting_data.get_target_size(_target_keyboard_mover.target)
		)


func _get_direction_input() -> Vector2i:
	return Vector2i(Input.get_vector(
			"step_west", "step_east", "step_north", "step_south"))


func _cancel_targeting() -> void:
	request_state_change(movement_state, { player = _player })


func _end_turn(target_cell: Vector2i) -> void:
	var action := AbilityAction.new(_player, target_cell, _ability)
	var data := { action = action }
	request_state_change(action_state, data)
