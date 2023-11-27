@tool
class_name ActorMap
extends Node2D


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
