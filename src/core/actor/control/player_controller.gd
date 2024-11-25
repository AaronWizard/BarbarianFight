class_name PlayerController
extends ActorController

## A node for controlling player actors.
##
## A node for controlling player actors. On the actor's turn, waits for player
## input.

## The player actor's turn has started and is waiting for input.
signal player_turn_started

# Private signal.
signal _turn_chosen(action: TurnAction)


func get_turn_action() -> TurnAction:
	player_turn_started.emit()

	@warning_ignore("unsafe_cast")
	var action := await _turn_chosen as TurnAction

	return action


## Set the action for the player actor to do on its turn.
func do_player_action(action: TurnAction) -> void:
	_turn_chosen.emit(action)
