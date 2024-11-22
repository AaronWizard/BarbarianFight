class_name MoveAction
extends TurnAction


## A turn action where an actor moves to an adjacent cell.


var _actor: Actor
var _next_cell: Vector2i


func _init(actor: Actor, next_cell: Vector2i) -> void:
	_actor = actor
	_next_cell = next_cell


func wait_for_map_anims() -> bool:
	return false


func run() -> void:
	if not _actor.map.actor_can_enter_cell(_actor, _next_cell):
		push_error("Actor '%s' tried to enter cell %v" % [_actor, _next_cell])
	else:
		_actor.move_step(_next_cell)
