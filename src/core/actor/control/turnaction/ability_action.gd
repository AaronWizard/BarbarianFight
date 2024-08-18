class_name AbilityAction
extends TurnAction

## A turn action where an actor performs an ability.

var _target_actor: Actor
var _target: Vector2i
var _ability: Ability


func _init(target_actor: Actor, target: Vector2i, ability: Ability) -> void:
	_target_actor = target_actor
	_target = target
	_ability = ability


func run() -> void:
	await _ability.perform(_target, _target_actor)
