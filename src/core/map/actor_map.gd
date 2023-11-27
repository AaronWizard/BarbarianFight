class_name ActorMap
extends Node2D


var actors: Array[Actor]:
	get:
		var result: Array[Actor] = []
		result.assign(get_children())
		return result
