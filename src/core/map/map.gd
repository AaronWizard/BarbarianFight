@icon("res://assets/editor/icons/map.png")
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


## The cell the mouse is currently over.
var mouse_cell: Vector2i:
	get:
		var mouse_pos := _terrain_tilemap.get_local_mouse_position()
		var result := _terrain_tilemap.local_to_map(mouse_pos)
		return result


var _terrain: Terrain
var _anim_tracker: MapAnimTracker
var _pathfinder: Pathfinder

@onready var _terrain_tilemap := $Terrain as TileMapLayer


func _ready() -> void:
	_terrain = Terrain.new(_terrain_tilemap)
	_anim_tracker = MapAnimTracker.new()
	@warning_ignore("return_value_discarded")
	_anim_tracker.animations_finished.connect(_on_animations_finished)

	_pathfinder = Pathfinder.new(_terrain_tilemap.get_used_rect())
	for wall in _terrain.all_blocking_cells():
		_pathfinder.set_cell_solid(wall, true)

	for a in actor_map.actors:
		_init_actor(a)


## Adds [param actor] to the map at [param cell].
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


func cleanup_dead_actors() -> void:
	var dead_actors: Array[Actor] = []
	for actor in actor_map.actors:
		if not actor.stamina.is_alive:
			actor.sprite.dissolve()
			dead_actors.append(actor)

	if not dead_actors.is_empty() and animations_playing:
		await animations_finished

	for actor in dead_actors:
		remove_actor(actor)


## True if [param actor] can have its origin_cell property set to [param cell],
## false otherwise. Checks both terrain and other actors.
func actor_can_enter_cell(actor: Actor, cell: Vector2i) -> bool:
	var actor_rect := actor.rect_at_cell(cell)
	return terrain.rect_allows_movement(actor_rect) \
			and actor_map.rect_is_clear(actor_rect, [actor])


## Finds a path that would move [param start_rect] to a position adjacent to
## [param end_rect]. If no valid path exists the result is empty.
func find_path_between_rects(start_rect: Rect2i, end_rect: Rect2i) \
		-> Array[Vector2i]:
	return _pathfinder.find_path_between_rects(start_rect, end_rect)


func _on_animations_finished() -> void:
	animations_finished.emit()


func _on_actor_moved(old_cell: Vector2i, actor: Actor) -> void:
	_pathfinder.set_rect_solid(actor.rect_at_cell(old_cell), false)
	_pathfinder.set_rect_solid(actor.rect, true)


func _init_actor(actor: Actor) -> void:
	actor.set_map(self)
	_anim_tracker.observe_actor(actor)
	@warning_ignore("return_value_discarded")
	actor.moved.connect(_on_actor_moved.bind(actor))

	_pathfinder.init_grid_for_actor_size(
		Vector2i(actor.cell_size, actor.cell_size)
	)
	_pathfinder.set_rect_solid(actor.rect, true)


func _uninit_actor(actor: Actor) -> void:
	_pathfinder.set_rect_solid(actor.rect, false)

	actor.set_map(null)
	_anim_tracker.unobserve_actor(actor)
	actor.moved.disconnect(_on_actor_moved)
