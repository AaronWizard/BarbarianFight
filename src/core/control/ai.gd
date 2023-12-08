class_name AI
extends Node

## An AI that picks actions for a parent actor on its turn.

## The AI's actor.
var _actor: Actor


## Sets the AI's actor.
func set_actor(actor: Actor) -> void:
	assert(actor.is_ancestor_of(self))
	_actor = actor


## Gets the AI's next turn action. A return value of null is a wait action.
func get_action() -> TurnAction:
	print("Running AI")
	await get_tree().create_timer(0.1).timeout
	return null
