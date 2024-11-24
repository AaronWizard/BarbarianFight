class_name ActorController
extends Node

## A node for controlling actors.
##
## A node for controlling actors. Selects the actor's action on its turn.


## Gets the actor's turn action.[br]
## Can be overriden.
func get_turn_action() -> TurnAction:
	push_warning("ActorController._get_turn_action not implemented")
	return null
