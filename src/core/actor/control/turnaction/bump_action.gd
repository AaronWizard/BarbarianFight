class_name BumpAction
extends TurnAction

## A turn action where an actor moves or attacks.
##
## A turn action where an actor moves or attacks. If the target cell is empty,
## the actor enters it. If the target cell has an enemy actor, the actor
## attacks.


var _target_actor: Actor
var _target_cell: Vector2i


func _init(target_actor: Actor, target_cell: Vector2i) -> void:
	_target_actor = target_actor
	_target_cell = target_cell
	assert(is_possible(_target_actor, _target_cell))


func run() -> void:
	var hit_actor := _target_actor.map.actor_map.get_actor_on_cell(_target_cell)

	var direction := _target_cell - _target_actor.origin_cell

	_target_actor.sprite.attack(direction)
	if _target_actor.sprite.animation_playing:
		await _target_actor.sprite.attack_anim_hit

	hit_actor.stamina.current_stamina -= _target_actor.definition.attack
	if hit_actor.stamina.is_alive:
		await hit_actor.sprite.hit(direction)
	else:
		hit_actor.sprite.die(direction)
		await hit_actor.sprite.animation_finished
		hit_actor.map.remove_actor(hit_actor)

	await _target_actor.sprite.wait_for_animation()


static func is_possible(target_actor: Actor, target_cell: Vector2i) -> bool:
	var other_actor := target_actor.map.actor_map.get_actor_on_cell(target_cell)
	return other_actor and target_actor.is_hostile(other_actor)
