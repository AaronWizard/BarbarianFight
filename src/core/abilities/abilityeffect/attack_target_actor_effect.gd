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

	var attack := Attack.new(data.source_actor.definition.attack)
	attack.set_source_rect(data.source_rect)

	Combat.attack_single_actor(target_actor, attack, true)
