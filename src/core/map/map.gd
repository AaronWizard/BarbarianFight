class_name Map
extends Node2D

## A game map.
##
## A game map. Has actors, terrain, and map markers.

## Emitted when all running animations are finished.
signal animations_finished

## The ActorMap containing the map's actors
var actor_map: ActorMap:
	get:
		return $ActorMap as ActorMap


## The MapMarkers containing markers on the map.
var markers: MapMarkers:
	get:
		return $MapMarkers as MapMarkers


## True if any animations are playing on the map, false otherwise.
var animations_playing: bool:
	get:
		return _anim_tracker.animations_playing


var _turn_clock: TurnClock
var _anim_tracker: MapAnimTracker

@onready var _terrain := $Terrain as Terrain


func _ready() -> void:
	_anim_tracker = MapAnimTracker.new()
	@warning_ignore("return_value_discarded")
	_anim_tracker.animations_finished.connect(_on_animations_finished)

	for a in actor_map.actors:
		_init_actor(a)


## Set the map's TurnClock. The turn clock will be set on the actors on the map.
func set_turn_clock(clock: TurnClock) -> void:
	_turn_clock = clock
	for a in actor_map.actors:
		a.set_turn_clock(_turn_clock)


## Adds [param actor] to the map at [param cell].[br]
## The new actor will be given the map's turn clock.
func add_actor(actor: Actor, cell: Vector2i) -> void:
	assert(actor.get_parent() == null)

	if actor_can_enter_cell(actor, cell):
		actor_map.add_child(actor)
		actor.origin_cell = cell
		_init_actor(actor)
	else:
		push_error("Can not place actor '%s' at cell %s" % [actor, cell])


## Removes [param actor] from the map.
func remove_actor(actor: Actor) -> void:
	assert(actor.get_parent() == actor_map)
	assert(actor.map == self)

	actor_map.remove_child(actor)
	_uninit_actor(actor)


## True if [param actor] can have its origin_cell property set to [param cell],
## false otherwise.
func actor_can_enter_cell(actor: Actor, cell: Vector2i) -> bool:
	return _terrain.tile_object_can_enter_cell(actor, cell) \
			and actor_map.actor_can_enter_cell(actor, cell)


func _on_animations_finished() -> void:
	animations_finished.emit()


func _init_actor(actor: Actor) -> void:
	actor.set_map(self)
	actor.set_turn_clock(_turn_clock)
	_anim_tracker.observe_actor(actor)


func _uninit_actor(actor: Actor) -> void:
	actor.set_map(null)
	actor.set_turn_clock(null)
	_anim_tracker.unobserve_actor(actor)
