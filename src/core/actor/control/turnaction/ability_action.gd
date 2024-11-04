class_name AbilityAction
extends TurnAction

## A turn action where an actor performs an ability.

var _actor: Actor
var _target: Vector2i
var _ability: Ability


func _init(actor: Actor, target: Vector2i, ability: Ability) -> void:
	_actor = actor
	_target = target
	_ability = ability


func run() -> void:
	await _ability.perform(_target, _actor)
