class_name PlayerInput
extends Node

signal action_chosen(turn_action: TurnAction)

var _player_actor: Actor


var enabled: bool:
	set(value):
		enabled = value
		set_process_unhandled_input(enabled)


func _ready() -> void:
	enabled = false


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_released("wait"):
		action_chosen.emit(null)
	else:
		var action := _try_walk()
		if action:
			action_chosen.emit(action)


func set_player_actor(actor: Actor) -> void:
	_player_actor = actor


func _try_walk() -> TurnAction:
	var result: TurnAction = null

	var direction := Vector2i(Input.get_vector(
			"step_west", "step_east", "step_north", "step_south"))
	if direction.length_squared() == 1:
		var target_cell := _player_actor.origin_cell + direction
		result = BumpAction.new(_player_actor, target_cell)

	return result
