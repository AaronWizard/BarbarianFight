@tool
class_name ActorMap
extends Node2D

## A grid map of actors.


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


## True if [param actor] can have its origin_cell property set to
## [param cell] without overlapping other actors, false otherwise.
func actor_can_enter_cell(actor: Actor, cell: Vector2i) -> bool:
	var result := true

	for covered in actor.covered_cells_at_cell(cell):
		var other_actor := get_actor_on_cell(covered)
		if other_actor and (other_actor != actor):
			result = false
			break

	return result
