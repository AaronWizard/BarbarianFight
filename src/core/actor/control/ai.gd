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

	result = _try_attack()
	if not result:
		result = _find_step_to_enemy()

	return result


func _try_attack() -> TurnAction:
	var result: TurnAction = null

	@warning_ignore("untyped_declaration")
	for d in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]:
		@warning_ignore("unsafe_cast")
		var next_cell := _actor.origin_cell + (d as Vector2i)
		var other_actor := _actor.map.actor_map.get_actor_on_cell(next_cell)
		if other_actor and other_actor.is_hostile(_actor):
			assert(BumpAction.is_possible(_actor, next_cell))
			result = BumpAction.new(_actor, next_cell)
			break

	return result


func _find_step_to_enemy() -> TurnAction:
	var result: TurnAction = null

	var path: Array[Vector2i] = []
	for actor in _actor.map.actor_map.actors:
		if actor.is_hostile(_actor):
			var new_path := _actor.map.find_path_to_rect_adjacent_cell(
					_actor.origin_cell, actor.rect, _actor.rect.size)
			if not new_path.is_empty() \
					and (path.is_empty() or (new_path.size() < path.size())):
				path = new_path
	if not path.is_empty():
		assert(path.size() > 1)
		result = MoveAction.new(_actor, path[1])

	return result
