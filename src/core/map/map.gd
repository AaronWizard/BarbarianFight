class_name Map
extends Node2D

## A game map.
##
## A game map. Has actors, terrain, and map markers.


## The ActorMap containing the map's actors
var actors: ActorMap:
	get:
		return $ActorMap as ActorMap


## The MapMarkers containing markers on the map.
var markers: MapMarkers:
	get:
		return $MapMarkers as MapMarkers


var _turn_clock: TurnClock


## Set the map's TurnClock. The turn clock will be set on the actors on the map.
func set_turn_clock(clock: TurnClock) -> void:
	_turn_clock = clock
	for a in actors.actors:
		a.set_turn_clock(_turn_clock)


## Adds [param actor] to the map at [param cell].[br]
## The new actor will be given the map's turn clock.
func add_actor(actor: Actor, cell: Vector2i) -> void:
	assert(actor.get_parent() == null)
	assert(actors.actor_can_enter_cell(actor, cell))
	actor.origin_cell = cell
	actors.add_child(actor)

	if _turn_clock:
		actor.set_turn_clock(_turn_clock)
