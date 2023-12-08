class_name BumpAction
extends TurnAction


var _target_actor: Actor
var _target_cell: Vector2i


func _init(target_actor: Actor, target_cell: Vector2i) -> void:
	_target_actor = target_actor
	_target_cell = target_cell


func run() -> void:
	_target_actor.origin_cell = _target_cell
