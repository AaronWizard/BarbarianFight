class_name PlayerActionState
extends State

signal player_action_chosen(turn_action: TurnAction)

@export var wait_state: State


func enter(data := {}) -> void:
	@warning_ignore("unsafe_cast")
	var action := data.action as TurnAction
	player_action_chosen.emit(action)

	request_state_change(wait_state)
