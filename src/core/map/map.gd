class_name Map
extends Node2D

## A game map.
##
## A game map. Has actors, terrain, and map markers.

## Emitted when an actor is added to the map.
signal actor_added(actor: Actor)

## Emitted when an actor  is removed from the map.
signal actor_removed(actor: Actor)

## Emitted when all running animations are finished.
signal animations_finished


## The map's terrain.
var terrain: Terrain:
	get:
		return _terrain


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


## The bounds of the map in pixels.
var pixel_rect: Rect2i:
	get:
		var cell_rect := _terrain_tilemap.get_used_rect()
		var tile_size := _terrain_tilemap.tile_set.tile_size
		var rectpos := Vector2(cell_rect.position * tile_size)
		var rectsize := Vector2(cell_rect.size * tile_size)
		return Rect2i(rectpos, rectsize)


var _terrain: Terrain
var _turn_clock: TurnClock
var _anim_tracker: MapAnimTracker

@onready var _terrain_tilemap := $Terrain as TileMapLayer


func _ready() -> void:
	_terrain = Terrain.new(_terrain_tilemap)
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
		actor_added.emit(actor)
	else:
		push_error("Can not place actor '%s' at cell %s" % [actor, cell])


## Removes [param actor] from the map.
func remove_actor(actor: Actor) -> void:
	assert(actor.get_parent() == actor_map)
	assert(actor.map == self)

	actor_map.remove_child(actor)
	_uninit_actor(actor)
	actor_removed.emit(actor)


## True if [param actor] can have its origin_cell property set to [param cell],
## false otherwise. Checks both terrain and other actors.
func actor_can_enter_cell(actor: Actor, cell: Vector2i) -> bool:
	return terrain.tile_object_can_enter_cell(actor, cell) \
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
