class_name AttackTargetActorEffect
extends AbilityEffect

## Damages the target actor based on the source actor's stats and the direction
## from the source rectangle.


func apply(target: Vector2i, source: Rect2i, source_actor: Actor) -> void:
	var target_actor := source_actor.map.actor_map.get_actor_on_cell(target)

	if not target_actor:
		push_error("No actor to attack")
		return
	if target_actor == source_actor:
		push_error("Actor '%s' can't attack itself" % source_actor)
		return

	var direction := TileGeometry.cardinal_dir_from_rect_to_cell(
			source, target)

	target_actor.stamina.current_stamina -= source_actor.definition.attack
	if target_actor.stamina.is_alive:
		await target_actor.sprite.hit(direction)
	else:
		await target_actor.sprite.die(direction)
		target_actor.map.remove_actor(target_actor)
