class_name TurnAction

## An object representing an actor's turn action.


## True if this turn action should only be run after all existing animations in
## the current map have finished, false otherwise. Can be overriden.
func wait_for_map_anims() -> bool:
	return true


## Executes the action.
func run() -> void:
	push_warning("TurnAction.run not implemented")
