class_name AttackTargetActorEffect
extends AbilityEffect

## Damages the target actor based on the source actor's stats and the direction
## from the source rectangle.


func apply(data: AbilityData) -> void:
	var target_actor := data.map.actor_map.get_actor_on_cell(data.target)

	if not target_actor:
		push_error("No actor to attack")
		return
	if target_actor == data.source_actor:
		push_error("Actor '%s' can't attack itself" % data.source_actor)
		return

	var direction := TileGeometry.cardinal_dir_between_rects(
			data.source_rect, target_actor.rect)
	var damage := data.source_actor.definition.attack

	await target_actor.take_damage(damage, direction)
