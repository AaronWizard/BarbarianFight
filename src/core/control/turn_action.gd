class_name TurnAction

## An object representing an actor's turn action.


## The speed of the action. Can be overriden.
func get_action_speed() -> TurnConstants.ActionSpeed:
	return TurnConstants.ActionSpeed.MEDIUM


## Executes the action.
func run() -> void:
	push_warning("TurnAction.run not implemented")
