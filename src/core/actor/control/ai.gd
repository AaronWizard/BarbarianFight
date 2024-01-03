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

	var enemy := _find_enemy()
	if enemy:
		var delta := enemy.origin_cell - _actor.origin_cell
		delta = delta.sign()
		if delta.length_squared() > 1:
			delta.y = 0
		var next_cell := _actor.origin_cell + delta
		assert(BumpAction.is_possible(_actor, next_cell))

		result = BumpAction.new(_actor, next_cell)

	return result


func _find_enemy() -> Actor:
	var result: Actor = null
	for actor in _actor.map.actor_map.actors:
		if actor.is_hostile(_actor):
			result = actor
			break
	return result
