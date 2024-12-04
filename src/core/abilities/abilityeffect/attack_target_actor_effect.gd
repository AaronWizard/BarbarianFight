class_name AttackTargetActorEffect
extends AbilityEffect

## Damages the target actor based on the source actor's stats and the direction
## from the source rectangle.


func apply(target: Vector2i, source: Rect2i, source_actor: Actor) -> void:
	var target_actor := source_actor.map.actor_map.get_actor_on_cell(target)

	if target_actor == source_actor:
		push_error("Actor '%s' can't attack itself" % source_actor)
		return

	var attack_data := AttackData.new()
	attack_data.attack_power = source_actor.definition.attack
	attack_data.has_source_rect = true
	attack_data.source_rect = source
	attack_data.source_actor = source_actor

	await source_actor.map.combat_physics.do_attack(
		[target], attack_data
	)
