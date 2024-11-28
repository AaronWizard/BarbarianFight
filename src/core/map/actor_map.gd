@tool
class_name ActorMap
extends Node2D

## A grid map of actors.
##
## A grid map of actors. For querying what actors are at what cells, and
## for checking where an actor would overlap with other actors.


## The actors in the actor map.
var actors: Array[Actor]:
	get:
		var result: Array[Actor] = []
		result.assign(get_children())
		return result


func _get_configuration_warnings() -> PackedStringArray:
	var result := []
	for c in get_children():
		if not c is Actor:
			result.append("'%s' is not of type 'Actor'" % c)
	return PackedStringArray(result)


## Gets the actor covering [param cell], or null if [param cell] is empty.
## Assumes actors are not overlapping.
func get_actor_on_cell(cell: Vector2i) -> Actor:
	var result: Actor = null
	for a in actors:
		if a.covers_cell(cell):
			result = a
			break
	return result


func get_actors_on_cells(cells: Array[Vector2i]) -> Array[Actor]:
	var found_actors := {}

	for cell in cells:
		var actor := get_actor_on_cell(cell)
		if actor:
			found_actors[actor] = true

	var result: Array[Actor] = []
	result.assign(found_actors.keys())

	return result


## True if [param rect] does not overlap with any actors in the actor map other
## than the ones in [param actors_to_ignore], false otherwise.
func rect_is_clear(rect: Rect2i, actors_to_ignore: Array[Actor]) -> bool:
	var result := true

	for covered in TileGeometry.cells_in_rect(rect):
		var other_actor := get_actor_on_cell(covered)
		if other_actor and other_actor not in actors_to_ignore:
			result = false
			break

	return result
