class_name AbilityAction
extends TurnAction

## A turn action where an actor performs an ability.


var _target_actor: Actor
var _target_cell: Vector2i
var _ability: Ability


func _init(target_actor: Actor, target_cell: Vector2i, ability: Ability) \
		-> void:
	_target_actor = target_actor
	_target_cell = target_cell
	_ability = ability


func run() -> void:
	await _ability.perform(_target_cell, _target_actor)
