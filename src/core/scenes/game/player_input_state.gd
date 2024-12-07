class_name PlayerInputState
extends PlayerState

@export var wait_state: State


## Ends the player's turn with the given action.
func _end_turn(action: TurnAction) -> void:
	game_control.player_controller.do_player_action(action)
	request_state_change(wait_state)
