@icon("res://assets/editor/icons/ai.png")
class_name AIController
extends ActorController

## An AI node for controlling NPC actors.


func get_turn_action() -> TurnAction:
	var result: TurnAction = null

	result = _try_ability()
	if not result:
		result = _find_step_to_enemy()

	return result


func _try_ability() -> TurnAction:
	var result: TurnAction = null

	var possible_abilities := {}

	for ability in controlled_actor.all_abilities:
		var target_data := ability.get_target_data(controlled_actor)
		if target_data.has_targets:
			possible_abilities[ability] = target_data

	if not possible_abilities.is_empty():
		@warning_ignore("unsafe_cast")
		var ability := possible_abilities.keys().pick_random() as Ability
		@warning_ignore("unsafe_cast")
		var target_data := possible_abilities[ability] as TargetingData

		@warning_ignore("unsafe_cast")
		var target := target_data.targets.pick_random() as Vector2i

		result = AbilityAction.new(controlled_actor, target, ability)

	return result


func _find_step_to_enemy() -> TurnAction:
	var result: TurnAction = null

	var path: Array[Vector2i] = []
	for actor in controlled_actor.map.actor_map.actors:
		if actor.is_hostile(controlled_actor):
			var new_path := controlled_actor.map.find_path_between_rects(
					controlled_actor.rect, actor.rect)
			if not new_path.is_empty() \
					and (path.is_empty() or (new_path.size() < path.size())):
				path = new_path
	if not path.is_empty():
		assert(path.size() > 1)
		result = MoveAction.new(controlled_actor, path[1])

	return result
