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
	var direction := TileGeometry.cardinal_dir_from_rect_to_cell(
			_actor.rect, _target)
	await _actor.sprite.attack_windup(direction)

	await _actor.map.combat_physics.warn_of_attack(_ability.get_aoe(_target), AttackData.new())
	await _ability.perform(_target, _actor)
	await _actor.get_tree().create_timer(0.3).timeout
