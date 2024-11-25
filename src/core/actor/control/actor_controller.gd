class_name ActorController
extends Node

## A node for controlling actors.
##
## A node for controlling actors. Selects the actor's action on its turn.


## The actor being controlled.
var controlled_actor: Actor:
	get:
		return _controlled_actor


func _ready() -> void:
	if owner is Actor:
		(owner as Actor).set_controller(self)


## Set the controlled actor. Not meant to be used directly. Use
## [method Actor.set_controller].
func set_actor(new_actor: Actor) -> void:
	if (_controlled_actor and _controlled_actor.is_ancestor_of(self)) \
			or (new_actor and not new_actor.is_ancestor_of(self)):
		push_error("Controlled actor not set with Actor.set_controller")
	else:
		_controlled_actor = new_actor


var _controlled_actor: Actor


## Gets the actor's turn action.[br]
## Can be overriden.
func get_turn_action() -> TurnAction:
	push_warning("ActorController._get_turn_action not implemented")
	return null
