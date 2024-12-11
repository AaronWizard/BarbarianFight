class_name PlayerTargetState
extends PlayerInputState

## Player control state where the player is selecting a target for an ability.

## The state for standard player movement and attacks.
@export var movement_state: PlayerMovementState

## Displays the target range and current target.
@export var target_display: TargetDisplay

## The button to make the player actor wait a turn. Will hide this button when
## targeting.
@export var wait_button: CanvasItem

# Also used to keep track of the currently selected target.
var _target_keyboard_mover := PlayerTargetKeyboardMover.new()

var _targetting_data: TargetingData

@onready var _ability_display := $CanvasLayer/AbilityDisplay as AbilityDisplay


func _ready() -> void:
	@warning_ignore("return_value_discarded")
	_ability_display.cancelled.connect(_on_ability_cancelled)
	_ability_display.visible = false


func enter() -> void:
	_targetting_data = game_control.selected_ability.get_target_data(
			player_actor)

	var initial_target := game_control.initial_ability_target
	if not _targetting_data.targets.is_empty() \
			and (initial_target not in _targetting_data.targets):
		initial_target = _targetting_data.targets[0]

	_target_keyboard_mover.set_targets(_targetting_data.targets, initial_target)
	target_display.show_range(_targetting_data, initial_target)

	_ability_display.set_ability_name(game_control.selected_ability.name)

	_ability_display.visible = true
	wait_button.visible = false


func exit() -> void:
	target_display.clear()
	_target_keyboard_mover.clear()

	_targetting_data = null

	_ability_display.visible = false


func handle_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("click"):
		_try_click()
	elif Input.is_action_just_released("targeting_cancel"):
		_cancel_targeting()
	elif _targetting_data.has_targets:
		if Input.is_action_just_released("wait"):
			_use_ability(_target_keyboard_mover.target)
		else:
			_try_move_target()


func _on_ability_cancelled() -> void:
	_cancel_targeting()


func _try_click() -> void:
	var cell := player_actor.map.mouse_cell
	if _targetting_data.has_target_for_cell(cell):
		var target := _targetting_data.target_at_selected_cell(cell)
		if target == _target_keyboard_mover.target:
			_use_ability(target)
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
	request_state_change(movement_state)


func _use_ability(target_cell: Vector2i) -> void:
	var action := AbilityAction.new(
			player_actor, target_cell, game_control.selected_ability)
	_end_turn(action)
