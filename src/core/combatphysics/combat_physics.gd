class_name CombatPhysics

## A class for handling combat and physics on a map.
##
## A class for handling combat and physics on a map. Handles actions like
## applying damage and pushing actors.

var _map: Map


func _init(map: Map) -> void:
	_map = map


func do_attack(aoe: Array[Vector2i], attack_power: int, source_rect: Rect2i) \
		-> void:
	var actors := _map.actor_map.get_actors_on_cells(aoe)
	for actor in actors:
		@warning_ignore("redundant_await")
		await actor.controller.get_attack_reaction(
				aoe, attack_power, source_rect)

	actors = _map.actor_map.get_actors_on_cells(aoe)
	for actor in actors:
		var direction := TileGeometry.cardinal_dir_between_rects(
				source_rect, actor.rect)
		await actor.take_damage(attack_power, direction)
