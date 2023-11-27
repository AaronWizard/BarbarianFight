class_name Map
extends Node2D


var actors: ActorMap:
	get:
		return $ActorMap as ActorMap


var markers: MapMarkers:
	get:
		return $MapMarkers as MapMarkers


func add_actor(actor: Actor, cell: Vector2i) -> void:
	assert(actor.get_parent() == null)
	assert(actors.actor_can_enter_cell(actor, cell))
	actor.origin_cell = cell
	actors.add_child(actor)
