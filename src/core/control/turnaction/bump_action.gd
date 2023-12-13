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
	assert(BumpAction.is_possible(_target_actor, _target_cell))


func run() -> void:
	if BumpAction._can_move_to_target(_target_actor, _target_cell):
		_target_actor.move_step(_target_cell)
	elif BumpAction._can_attack_target(_target_actor, _target_cell):
		await _target_actor.sprite.attack(_target_cell - _target_actor.origin_cell)


static func is_possible(target_actor: Actor, target_cell: Vector2i) -> bool:
	var result := _can_move_to_target(target_actor, target_cell) \
			or _can_attack_target(target_actor, target_cell)
	return result


static func _can_move_to_target(target_actor: Actor, target_cell: Vector2i) \
		-> bool:
	return target_actor.map.actor_can_enter_cell(target_actor, target_cell)


static func _can_attack_target(target_actor: Actor, target_cell: Vector2i) \
		-> bool:
	var other_actor := target_actor.map.actor_map.get_actor_on_cell(target_cell)
	return other_actor and (other_actor.faction != target_actor.faction)
