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

	result = _try_ability()
	if not result:
		result = _find_step_to_enemy()

	return result


func _try_ability() -> TurnAction:
	var result: TurnAction = null

	var possible_abilities := {}

	for ability in _actor.all_abilities:
		var target_data := ability.get_target_data(_actor)
		if target_data.has_targets:
			possible_abilities[ability] = target_data

	if not possible_abilities.is_empty():
		@warning_ignore("unsafe_cast")
		var ability := possible_abilities.keys().pick_random() as Ability
		@warning_ignore("unsafe_cast")
		var target_data := possible_abilities[ability] as TargetingData

		@warning_ignore("unsafe_cast")
		var target := target_data.targets.pick_random() as Rect2i

		result = AbilityAction.new(_actor, target.position, ability)

	return result


func _find_step_to_enemy() -> TurnAction:
	var result: TurnAction = null

	var path: Array[Vector2i] = []
	for actor in _actor.map.actor_map.actors:
		if actor.is_hostile(_actor):
			var new_path := _actor.map.find_path_between_rects(
					_actor.rect, actor.rect)
			if not new_path.is_empty() \
					and (path.is_empty() or (new_path.size() < path.size())):
				path = new_path
	if not path.is_empty():
		assert(path.size() > 1)
		result = MoveAction.new(_actor, path[1])

	return result
