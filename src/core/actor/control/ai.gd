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
	var result: TurnAction = null

	var actions: Array[TurnAction] = []

	for dir: Vector2i in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN,
			Vector2i.LEFT]:
		var target_cell := _actor.origin_cell + dir
		if BumpAction.is_possible(_actor, target_cell):
			actions.append(BumpAction.new(_actor, target_cell))

	if not actions.is_empty():
		actions.shuffle()
		result = actions.front()

	return result
