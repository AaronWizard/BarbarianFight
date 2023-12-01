class_name Brain
extends Node

## An object that picks actions for an actor.


## The brain's actor.
var _actor: Actor


## Sets the brain's actor.
func set_actor(actor: Actor) -> void:
	assert(actor.is_ancestor_of(self))
	_actor = actor


## Gets the brain's next turn action. A return value of null is a wait action.
func get_action() -> TurnAction:
	push_warning("Brain.get_action not implemented")
	return null
