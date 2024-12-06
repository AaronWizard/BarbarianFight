class_name PlayerActionState
extends State

## Player control state where the player actor is doing a turn action.
##
## Player control state where the player actor is doing a turn action. Input is
## blocked.

signal player_action_chosen(turn_action: TurnAction)

@export var wait_state: State


func enter() -> void:
	@warning_ignore("unsafe_cast")
	var action := data.action as TurnAction
	player_action_chosen.emit(action)

	request_state_change(wait_state)
