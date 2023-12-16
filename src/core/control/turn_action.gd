class_name TurnAction

## An object representing an actor's turn action.


## The speed of the action. Can be overriden.
func get_action_speed() -> TurnConstants.ActionSpeed:
	return TurnConstants.ActionSpeed.MEDIUM


## True if this turn action should only be run after all existing animations in
## the current map have finished, false otherwise. Can be overriden.
func wait_for_map_anims() -> bool:
	return true


## Executes the action.
func run() -> void:
	push_warning("TurnAction.run not implemented")
